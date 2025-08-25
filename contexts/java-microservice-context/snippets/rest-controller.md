# REST Controller Patterns

## Base REST Controller with Standard CRUD Operations

```java
@RestController
@RequestMapping("/api/v1/patients")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Patient Management", description = "APIs for managing patient records")
public class PatientController {

    private final PatientService patientService;
    private final PatientMapper patientMapper;

    @GetMapping
    @Operation(summary = "Get all patients", description = "Retrieve a paginated list of all patients")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Successfully retrieved patients"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public ResponseEntity<Page<PatientDTO>> getAllPatients(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "ASC") Sort.Direction direction) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        Page<Patient> patients = patientService.findAll(pageable);
        Page<PatientDTO> patientDTOs = patients.map(patientMapper::toDTO);
        
        return ResponseEntity.ok(patientDTOs);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get patient by ID", description = "Retrieve a specific patient by their ID")
    public ResponseEntity<PatientDTO> getPatientById(@PathVariable Long id) {
        Patient patient = patientService.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + id));
        
        return ResponseEntity.ok(patientMapper.toDTO(patient));
    }

    @PostMapping
    @Operation(summary = "Create new patient", description = "Create a new patient record")
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<PatientDTO> createPatient(
            @Valid @RequestBody CreatePatientRequest request) {
        
        Patient patient = patientMapper.toEntity(request);
        Patient savedPatient = patientService.save(patient);
        
        URI location = ServletUriComponentsBuilder
            .fromCurrentRequest()
            .path("/{id}")
            .buildAndExpand(savedPatient.getId())
            .toUri();
        
        return ResponseEntity.created(location).body(patientMapper.toDTO(savedPatient));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update patient", description = "Update an existing patient record")
    public ResponseEntity<PatientDTO> updatePatient(
            @PathVariable Long id,
            @Valid @RequestBody UpdatePatientRequest request) {
        
        Patient existingPatient = patientService.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Patient not found with id: " + id));
        
        patientMapper.updateEntity(request, existingPatient);
        Patient updatedPatient = patientService.save(existingPatient);
        
        return ResponseEntity.ok(patientMapper.toDTO(updatedPatient));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete patient", description = "Delete a patient record")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ResponseEntity<Void> deletePatient(@PathVariable Long id) {
        if (!patientService.existsById(id)) {
            throw new ResourceNotFoundException("Patient not found with id: " + id);
        }
        
        patientService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
```

## Request/Response DTOs with Validation

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreatePatientRequest {
    
    @NotBlank(message = "Name is required")
    @Size(max = 100, message = "Name must not exceed 100 characters")
    private String name;
    
    @NotBlank(message = "HKID is required")
    @Pattern(regexp = "[A-Z]\\d{6}\\([0-9A]\\)", message = "Invalid HKID format")
    private String hkid;
    
    @NotNull(message = "Date of birth is required")
    @Past(message = "Date of birth must be in the past")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate dateOfBirth;
    
    @NotNull(message = "Gender is required")
    @Pattern(regexp = "[MF]", message = "Gender must be M or F")
    private String gender;
    
    @Pattern(regexp = "\\d{8}", message = "Phone number must be 8 digits")
    private String phoneNumber;
    
    @Email(message = "Invalid email format")
    private String email;
    
    @Size(max = 500, message = "Address must not exceed 500 characters")
    private String address;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatientDTO {
    private Long id;
    private String name;
    private String hkid;
    private LocalDate dateOfBirth;
    private String gender;
    private String phoneNumber;
    private String email;
    private String address;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

## Global Exception Handler

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(
            ResourceNotFoundException ex, WebRequest request) {
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.NOT_FOUND.value())
            .error("Resource Not Found")
            .message(ex.getMessage())
            .path(request.getDescription(false).replace("uri=", ""))
            .build();
        
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex, WebRequest request) {
        
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.BAD_REQUEST.value())
            .error("Validation Failed")
            .message("Invalid input parameters")
            .validationErrors(errors)
            .path(request.getDescription(false).replace("uri=", ""))
            .build();
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
            Exception ex, WebRequest request) {
        
        log.error("Unexpected error occurred", ex);
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error("Internal Server Error")
            .message("An unexpected error occurred")
            .path(request.getDescription(false).replace("uri=", ""))
            .build();
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
    }
}
``` 