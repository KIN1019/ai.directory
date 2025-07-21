# Service Layer Implementation

## Base Service Class with Common Operations

```java
@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class PatientService {

    private final PatientRepository patientRepository;
    private final PatientMapper patientMapper;
    private final AuditService auditService;
    private final NotificationService notificationService;

    @Transactional(readOnly = true)
    public Page<Patient> findAll(Pageable pageable) {
        log.debug("Finding all patients with pageable: {}", pageable);
        return patientRepository.findAll(pageable);
    }

    @Transactional(readOnly = true)
    public Optional<Patient> findById(Long id) {
        log.debug("Finding patient by id: {}", id);
        return patientRepository.findById(id);
    }

    @Transactional(readOnly = true)
    public Optional<Patient> findByHkid(String hkid) {
        log.debug("Finding patient by HKID: {}", hkid);
        return patientRepository.findByHkid(hkid);
    }

    @Transactional(readOnly = true)
    public Page<Patient> searchPatients(String query, Pageable pageable) {
        log.debug("Searching patients with query: {} and pageable: {}", query, pageable);
        
        if (StringUtils.isBlank(query)) {
            return findAll(pageable);
        }
        
        return patientRepository.findByNameContainingIgnoreCaseOrHkidContaining(
            query.trim(), query.trim(), pageable
        );
    }

    public Patient save(Patient patient) {
        log.debug("Saving patient: {}", patient);
        
        // Validate business rules
        validatePatient(patient);
        
        // Check for duplicate HKID
        if (patient.getId() == null && patientRepository.existsByHkid(patient.getHkid())) {
            throw new DuplicateResourceException("Patient with HKID " + patient.getHkid() + " already exists");
        }
        
        // Set timestamps
        if (patient.getId() == null) {
            patient.setCreatedAt(LocalDateTime.now());
            patient.setCreatedBy(getCurrentUser());
        }
        patient.setUpdatedAt(LocalDateTime.now());
        patient.setUpdatedBy(getCurrentUser());
        
        Patient savedPatient = patientRepository.save(patient);
        
        // Audit logging
        auditService.logPatientOperation(
            patient.getId() == null ? AuditAction.CREATE : AuditAction.UPDATE,
            savedPatient,
            getCurrentUser()
        );
        
        // Send notification for new patients
        if (patient.getId() == null) {
            notificationService.notifyPatientRegistration(savedPatient);
        }
        
        log.info("Successfully saved patient with id: {}", savedPatient.getId());
        return savedPatient;
    }

    public void deleteById(Long id) {
        log.debug("Deleting patient by id: {}", id);
        
        Patient patient = findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + id));
        
        // Check if patient has active appointments
        if (hasActiveAppointments(id)) {
            throw new BusinessRuleViolationException("Cannot delete patient with active appointments");
        }
        
        // Soft delete
        patient.setDeletedAt(LocalDateTime.now());
        patient.setDeletedBy(getCurrentUser());
        patientRepository.save(patient);
        
        // Audit logging
        auditService.logPatientOperation(AuditAction.DELETE, patient, getCurrentUser());
        
        log.info("Successfully deleted patient with id: {}", id);
    }

    @Transactional(readOnly = true)
    public boolean existsById(Long id) {
        return patientRepository.existsById(id);
    }

    @Transactional(readOnly = true)
    public long count() {
        return patientRepository.count();
    }

    private void validatePatient(Patient patient) {
        if (patient == null) {
            throw new IllegalArgumentException("Patient cannot be null");
        }
        
        if (StringUtils.isBlank(patient.getName())) {
            throw new ValidationException("Patient name is required");
        }
        
        if (StringUtils.isBlank(patient.getHkid())) {
            throw new ValidationException("Patient HKID is required");
        }
        
        if (!isValidHkid(patient.getHkid())) {
            throw new ValidationException("Invalid HKID format");
        }
        
        if (patient.getDateOfBirth() == null) {
            throw new ValidationException("Date of birth is required");
        }
        
        if (patient.getDateOfBirth().isAfter(LocalDate.now())) {
            throw new ValidationException("Date of birth cannot be in the future");
        }
    }

    private boolean isValidHkid(String hkid) {
        // HKID format: A123456(7)
        String pattern = "^[A-Z]\\d{6}\\([0-9A]\\)$";
        return hkid != null && hkid.matches(pattern);
    }

    private boolean hasActiveAppointments(Long patientId) {
        // Check if patient has appointments in the future
        return appointmentRepository.countByPatientIdAndAppointmentDateAfter(
            patientId, LocalDateTime.now()
        ) > 0;
    }

    private String getCurrentUser() {
        // Get current user from security context
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null ? authentication.getName() : "system";
    }
}
```

## Business Logic Service with Domain Events

```java
@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final PatientService patientService;
    private final DoctorService doctorService;
    private final ApplicationEventPublisher eventPublisher;
    private final NotificationService notificationService;

    public Appointment scheduleAppointment(ScheduleAppointmentRequest request) {
        log.debug("Scheduling appointment: {}", request);
        
        // Validate request
        validateAppointmentRequest(request);
        
        // Check patient exists
        Patient patient = patientService.findById(request.getPatientId())
            .orElseThrow(() -> new ResourceNotFoundException("Patient not found"));
        
        // Check doctor exists and is available
        Doctor doctor = doctorService.findById(request.getDoctorId())
            .orElseThrow(() -> new ResourceNotFoundException("Doctor not found"));
        
        if (!doctor.isAvailable()) {
            throw new BusinessRuleViolationException("Doctor is not available");
        }
        
        // Check time slot availability
        if (isTimeSlotTaken(request.getDoctorId(), request.getAppointmentDate())) {
            throw new BusinessRuleViolationException("Time slot is already taken");
        }
        
        // Create appointment
        Appointment appointment = Appointment.builder()
            .patient(patient)
            .doctor(doctor)
            .appointmentDate(request.getAppointmentDate())
            .duration(request.getDuration())
            .reason(request.getReason())
            .status(AppointmentStatus.SCHEDULED)
            .createdAt(LocalDateTime.now())
            .createdBy(getCurrentUser())
            .build();
        
        Appointment savedAppointment = appointmentRepository.save(appointment);
        
        // Publish domain event
        eventPublisher.publishEvent(new AppointmentScheduledEvent(savedAppointment));
        
        log.info("Successfully scheduled appointment with id: {}", savedAppointment.getId());
        return savedAppointment;
    }

    public Appointment confirmAppointment(Long appointmentId) {
        log.debug("Confirming appointment: {}", appointmentId);
        
        Appointment appointment = findById(appointmentId)
            .orElseThrow(() -> new ResourceNotFoundException("Appointment not found"));
        
        if (appointment.getStatus() != AppointmentStatus.SCHEDULED) {
            throw new BusinessRuleViolationException("Only scheduled appointments can be confirmed");
        }
        
        appointment.setStatus(AppointmentStatus.CONFIRMED);
        appointment.setConfirmedAt(LocalDateTime.now());
        appointment.setUpdatedAt(LocalDateTime.now());
        appointment.setUpdatedBy(getCurrentUser());
        
        Appointment confirmedAppointment = appointmentRepository.save(appointment);
        
        // Publish domain event
        eventPublisher.publishEvent(new AppointmentConfirmedEvent(confirmedAppointment));
        
        log.info("Successfully confirmed appointment with id: {}", appointmentId);
        return confirmedAppointment;
    }

    public void cancelAppointment(Long appointmentId, String reason) {
        log.debug("Cancelling appointment: {} with reason: {}", appointmentId, reason);
        
        Appointment appointment = findById(appointmentId)
            .orElseThrow(() -> new ResourceNotFoundException("Appointment not found"));
        
        if (appointment.getStatus() == AppointmentStatus.CANCELLED) {
            throw new BusinessRuleViolationException("Appointment is already cancelled");
        }
        
        if (appointment.getStatus() == AppointmentStatus.COMPLETED) {
            throw new BusinessRuleViolationException("Cannot cancel completed appointment");
        }
        
        appointment.setStatus(AppointmentStatus.CANCELLED);
        appointment.setCancellationReason(reason);
        appointment.setCancelledAt(LocalDateTime.now());
        appointment.setUpdatedAt(LocalDateTime.now());
        appointment.setUpdatedBy(getCurrentUser());
        
        appointmentRepository.save(appointment);
        
        // Publish domain event
        eventPublisher.publishEvent(new AppointmentCancelledEvent(appointment));
        
        log.info("Successfully cancelled appointment with id: {}", appointmentId);
    }

    @EventListener
    @Async
    public void handleAppointmentScheduled(AppointmentScheduledEvent event) {
        log.debug("Handling appointment scheduled event: {}", event);
        
        Appointment appointment = event.getAppointment();
        
        // Send confirmation email to patient
        notificationService.sendAppointmentConfirmation(appointment);
        
        // Send notification to doctor
        notificationService.notifyDoctorOfNewAppointment(appointment);
        
        // Update doctor's schedule
        doctorService.updateSchedule(appointment.getDoctor().getId(), appointment.getAppointmentDate());
    }

    private boolean isTimeSlotTaken(Long doctorId, LocalDateTime appointmentDate) {
        return appointmentRepository.existsByDoctorIdAndAppointmentDateAndStatusNot(
            doctorId, appointmentDate, AppointmentStatus.CANCELLED
        );
    }

    private void validateAppointmentRequest(ScheduleAppointmentRequest request) {
        if (request.getAppointmentDate().isBefore(LocalDateTime.now())) {
            throw new ValidationException("Appointment date cannot be in the past");
        }
        
        if (request.getDuration() <= 0) {
            throw new ValidationException("Appointment duration must be positive");
        }
        
        // Check business hours (9 AM to 5 PM)
        int hour = request.getAppointmentDate().getHour();
        if (hour < 9 || hour >= 17) {
            throw new BusinessRuleViolationException("Appointments can only be scheduled between 9 AM and 5 PM");
        }
    }
}
``` 