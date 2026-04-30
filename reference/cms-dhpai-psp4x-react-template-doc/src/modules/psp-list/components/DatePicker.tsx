import { useState, useRef, useMemo, useCallback } from "react";
import { DatePicker as ChassisDatePicker } from "@cmschassis/react-ui";
import { Box, Typography, Popover, IconButton, Button } from "@mui/material";
import {
	format,
	startOfMonth,
	endOfMonth,
	startOfWeek,
	endOfWeek,
	eachDayOfInterval,
	addMonths,
	subMonths,
	addYears,
	subYears,
	isSameMonth,
	isSameDay,
	getWeek,
	isToday,
} from "date-fns";
import { pspToolbarStyles, pspColors } from "../theme/pspTheme";

/**
 * Calendar icon matching PSP design with red header bar.
 */
function CalendarIcon(props: React.SVGProps<SVGSVGElement>) {
	return (
		<svg
			{...props}
			width="18"
			height="16"
			viewBox="0 0 18 16"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
		>
			{/* Calendar body outline */}
			<rect
				x="1"
				y="2"
				width="16"
				height="13"
				fill="#ffffff"
				stroke="#808080"
				strokeWidth="1"
			/>
			{/* Red header bar */}
			<rect x="1" y="2" width="16" height="3" fill="#800000" />
			{/* Grid lines */}
			<line x1="1" y1="8" x2="17" y2="8" stroke="#c0c0c0" strokeWidth="0.5" />
			<line x1="1" y1="11" x2="17" y2="11" stroke="#c0c0c0" strokeWidth="0.5" />
			<line x1="6" y1="5" x2="6" y2="15" stroke="#c0c0c0" strokeWidth="0.5" />
			<line x1="12" y1="5" x2="12" y2="15" stroke="#c0c0c0" strokeWidth="0.5" />
			{/* Calendar dots/numbers representation */}
			<rect x="3" y="6" width="1.5" height="1.5" fill="#808080" />
			<rect x="8" y="6" width="1.5" height="1.5" fill="#808080" />
			<rect x="14" y="6" width="1.5" height="1.5" fill="#808080" />
			<rect x="3" y="9" width="1.5" height="1.5" fill="#808080" />
			<rect x="8" y="9" width="1.5" height="1.5" fill="#808080" />
			<rect x="14" y="9" width="1.5" height="1.5" fill="#808080" />
			<rect x="3" y="12" width="1.5" height="1.5" fill="#808080" />
			<rect x="8" y="12" width="1.5" height="1.5" fill="#808080" />
		</svg>
	);
}

export interface DatePickerProps {
	/** Currently selected date */
	value: Date | null;
	/** Callback when date selection changes */
	onChange: (date: Date | null) => void;
	/** Label text displayed to the left of the input */
	label?: string;
	/** Whether the picker is disabled */
	disabled?: boolean;
	/** Placeholder text when no date is selected */
	placeholder?: string;
	/** Minimum selectable date */
	minDate?: Date;
	/** Maximum selectable date */
	maxDate?: Date;
}

/** Consistent row height for all calendar rows */
const ROW_HEIGHT = "22px";

/** Styles for the calendar popup */
const calendarStyles = {
	popup: {
		backgroundColor: "#d4d0c8",
		border: "2px outset #d4d0c8",
		padding: 0,
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		minWidth: "220px",
	},
	header: {
		display: "flex",
		alignItems: "center",
		justifyContent: "space-between",
		backgroundColor: "#808080",
		color: "#ffffff",
		height: ROW_HEIGHT,
		padding: "0 4px",
	},
	headerTitle: {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		fontWeight: 700,
		flex: 1,
		textAlign: "center" as const,
		lineHeight: ROW_HEIGHT,
	},
	closeButton: {
		color: "#ffffff",
		padding: "0px",
		minWidth: "16px",
		width: "16px",
		height: "16px",
		fontSize: "12px",
		lineHeight: 1,
		backgroundColor: "#c0c0c0",
		border: "1px outset #d4d0c8",
		borderRadius: 0,
		"&:hover": {
			backgroundColor: "#d0d0d0",
		},
	},
	navRow: {
		display: "grid",
		// Align with calendar grid: wk(28px) | Sun(1fr) | Mon-Thu(4fr) | Fri(1fr) | Sat(1fr)
		gridTemplateColumns: "28px 1fr 4fr 1fr 1fr",
		alignItems: "stretch",
		backgroundColor: "#d4d0c8",
		height: ROW_HEIGHT,
		borderTop: "1px solid #000000",
		borderBottom: "1px solid #000000",
	},
	navButton: {
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		padding: "0",
		minWidth: "unset",
		height: ROW_HEIGHT,
		fontSize: "14px",
		fontFamily: pspColors.fontFamily,
		backgroundColor: "#d4d0c8",
		border: "none",
		borderRight: "1px solid #000000",
		borderRadius: 0,
		color: "#808080",
		cursor: "pointer",
		"&:hover": {
			backgroundColor: "#e0e0e0",
		},
		"&:active": {
			backgroundColor: "#c0c0c0",
		},
	},
	navButtonLast: {
		borderRight: "none",
	},
	todayButton: {
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		padding: "0",
		minWidth: "unset",
		height: ROW_HEIGHT,
		fontSize: "12px",
		fontFamily: pspColors.fontFamily,
		backgroundColor: "#d4d0c8",
		border: "none",
		borderRight: "1px solid #000000",
		borderRadius: 0,
		color: "#000000",
		textTransform: "none" as const,
		cursor: "pointer",
		"&:hover": {
			backgroundColor: "#e0e0e0",
		},
	},
	calendarGrid: {
		backgroundColor: "#ffffff",
		margin: 0,
	},
	weekHeader: {
		display: "grid",
		gridTemplateColumns: "28px repeat(7, 1fr)",
		backgroundColor: "#d4d0c8",
		height: ROW_HEIGHT,
		borderBottom: "1px solid #000000",
	},
	weekHeaderWk: {
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 400,
		color: "#000000",
		backgroundColor: "#d4d0c8",
		borderRight: "1px solid #000000",
	},
	weekHeaderCell: {
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		fontWeight: 400,
		color: "#000000",
	},
	weekHeaderCellSunday: {
		color: "#800000",
	},
	weekRow: {
		display: "grid",
		gridTemplateColumns: "28px repeat(7, 1fr)",
		backgroundColor: "#ffffff",
		height: ROW_HEIGHT,
	},
	weekNumber: {
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		backgroundColor: "#d4d0c8",
		color: "#000000",
		borderRight: "1px solid #000000",
	},
	dayCell: {
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		cursor: "pointer",
		backgroundColor: "#ffffff",
		color: "#000000",
		border: "1px solid transparent",
		"&:hover": {
			backgroundColor: "#e8e8e8",
		},
	},
	dayCellSunday: {
		color: "#800000",
	},
	dayCellOutsideMonth: {
		color: "#808080",
	},
	dayCellSelected: {
		backgroundColor: "#c8daf0",
		border: "1px solid #0066cc",
	},
	dayCellToday: {
		fontWeight: 700,
	},
	selectButton: {
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		width: "100%",
		margin: 0,
		padding: 0,
		height: ROW_HEIGHT,
		fontFamily: pspColors.fontFamily,
		fontSize: "11px",
		backgroundColor: "#d4d0c8",
		border: "none",
		borderTop: "1px solid #000000",
		borderRadius: 0,
		color: "#000000",
		textTransform: "none" as const,
		"&:hover": {
			backgroundColor: "#e0e0e0",
		},
	},
} as const;

/**
 * Formats a date to the PSP display format (DD-Mmm-YYYY)
 */
function formatDateDisplay(date: Date | null): string {
	if (!date) return "";
	return format(date, "dd-MMM-yyyy");
}

const chassisInputOverrides = {
	"& .MuiInputBase-root, & .MuiOutlinedInput-root": {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		color: pspColors.selectText,
		backgroundColor: pspColors.selectBackground,
		borderRadius: "0px",
		height: "2em",
		minHeight: "unset",
		"& .MuiOutlinedInput-notchedOutline": {
			border: `0.5px solid ${pspColors.selectBorder}`,
			borderRadius: "0px",
		},
		"&:hover .MuiOutlinedInput-notchedOutline": {
			borderColor: pspColors.selectBorder,
		},
		"&.Mui-focused .MuiOutlinedInput-notchedOutline": {
			borderColor: pspColors.selectBorder,
			borderWidth: "0.5px",
		},
	},
	"& .MuiInputBase-input": {
		fontFamily: pspColors.fontFamily,
		fontSize: "12px",
		padding: "4px 8px",
		height: "unset",
		lineHeight: 1.4,
	},
	"& .MuiInputAdornment-root .MuiIconButton-root": {
		padding: "2px",
	},
	"& .MuiFormLabel-root": {
		display: "none",
	},
} as const;

/**
 * DatePicker using Chassis Calendar - Date Picker from @cmschassis/react-ui.
 * Wraps the Chassis component to maintain the same DatePickerProps interface.
 */
export function DatePicker({
	value,
	onChange,
	label,
	disabled = false,
	minDate,
	maxDate,
}: DatePickerProps) {
	const handleChange = useCallback(
		(date: Date | null) => {
			onChange(date);
		},
		[onChange],
	);

	const shouldDisableDate = useCallback(
		(date: Date | null): boolean => {
			if (!date) return false;
			if (minDate && date < minDate) return true;
			if (maxDate && date > maxDate) return true;
			return false;
		},
		[minDate, maxDate],
	);

	const needsDisableDate = minDate !== undefined || maxDate !== undefined;

	return (
		<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
			{label && (
				<Typography component="span" sx={pspToolbarStyles.label}>
					{label}
				</Typography>
			)}
			<Box sx={chassisInputOverrides}>
				<ChassisDatePicker
					value={value ?? undefined}
					onChange={handleChange}
					disabled={disabled}
					showInternalError={false}
					pickerProps={{ numberOfMonths: 1 }}
					{...(needsDisableDate ? { shouldDisableDate } : {})}
				/>
			</Box>
		</Box>
	);
}

/**
 * @deprecated Use DatePicker (Chassis-based) instead. Kept for reference.
 *
 * Legacy DatePicker component styled according to PSP design.
 * Displays an input field with calendar icon that opens a popup calendar.
 */
export function DatePickerLegacy({
	value,
	onChange,
	label,
	disabled = false,
	placeholder = "Select date",
	minDate,
	maxDate,
}: DatePickerProps) {
	const [anchorEl, setAnchorEl] = useState<HTMLElement | null>(null);
	const [viewDate, setViewDate] = useState<Date>(value ?? new Date());
	const inputRef = useRef<HTMLDivElement>(null);

	const open = Boolean(anchorEl);

	const handleOpen = useCallback(() => {
		if (!disabled) {
			setAnchorEl(inputRef.current);
			setViewDate(value ?? new Date());
		}
	}, [disabled, value]);

	const handleClose = useCallback(() => {
		setAnchorEl(null);
	}, []);

	const handleDateSelect = useCallback(
		(date: Date) => {
			onChange(date);
			handleClose();
		},
		[onChange, handleClose],
	);

	const handleTodayClick = useCallback(() => {
		const today = new Date();
		setViewDate(today);
	}, []);

	const handlePrevMonth = useCallback(() => {
		setViewDate((prev) => subMonths(prev, 1));
	}, []);

	const handleNextMonth = useCallback(() => {
		setViewDate((prev) => addMonths(prev, 1));
	}, []);

	const handlePrevYear = useCallback(() => {
		setViewDate((prev) => subYears(prev, 1));
	}, []);

	const handleNextYear = useCallback(() => {
		setViewDate((prev) => addYears(prev, 1));
	}, []);

	// Generate calendar days for the current view month
	const calendarWeeks = useMemo(() => {
		const monthStart = startOfMonth(viewDate);
		const monthEnd = endOfMonth(viewDate);
		const calendarStart = startOfWeek(monthStart, { weekStartsOn: 0 }); // Sunday start
		const calendarEnd = endOfWeek(monthEnd, { weekStartsOn: 0 });

		const days = eachDayOfInterval({ start: calendarStart, end: calendarEnd });
		const weeks: { weekNumber: number; days: Date[] }[] = [];

		for (let i = 0; i < days.length; i += 7) {
			const weekDays = days.slice(i, i + 7);
			weeks.push({
				weekNumber: getWeek(weekDays[0], { weekStartsOn: 0 }),
				days: weekDays,
			});
		}

		return weeks;
	}, [viewDate]);

	const isDateDisabled = useCallback(
		(date: Date): boolean => {
			if (minDate && date < minDate) return true;
			if (maxDate && date > maxDate) return true;
			return false;
		},
		[minDate, maxDate],
	);

	return (
		<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
			{label && (
				<Typography component="span" sx={pspToolbarStyles.label}>
					{label}
				</Typography>
			)}
			<Box
				ref={inputRef}
				sx={{
					display: "flex",
					alignItems: "center",
				}}
			>
				{/* Date input field */}
				<Box
					onClick={handleOpen}
					sx={{
						display: "flex",
						alignItems: "center",
						backgroundColor: disabled ? "#f5f5f5" : "#ffffff",
						border: `1px solid ${pspColors.selectBorder}`,
						borderRadius: 0,
						height: "27px",
						cursor: disabled ? "default" : "pointer",
						borderRight: "none",
						"&:hover": {
							borderColor: disabled ? pspColors.selectBorder : "#999999",
						},
					}}
				>
					<Typography
						sx={{
							fontFamily: pspColors.fontFamily,
							fontSize: "12px",
							color: value ? pspColors.selectText : "#999999",
							padding: "2px 8px",
							minWidth: "7em",
							lineHeight: 1.4,
						}}
					>
						{value ? formatDateDisplay(value) : placeholder}
					</Typography>
				</Box>
				{/* Calendar icon button */}
				<IconButton
					size="small"
					disabled={disabled}
					onClick={handleOpen}
					sx={{
						padding: "2px",
						borderRadius: 0,
						width: "30px",
						height: "27px",
						border: `1px solid ${pspColors.selectBorder}`,
						borderLeft: "none",
						backgroundColor: "#ececec",
						"&:hover": {
							backgroundColor: "#d8d8d8",
						},
						"&:disabled": {
							backgroundColor: "#f5f5f5",
						},
					}}
				>
					<CalendarIcon />
				</IconButton>
			</Box>

			<Popover
				open={open}
				anchorEl={anchorEl}
				onClose={handleClose}
				anchorOrigin={{
					vertical: "bottom",
					horizontal: "left",
				}}
				transformOrigin={{
					vertical: "top",
					horizontal: "left",
				}}
				slotProps={{
					paper: {
						sx: calendarStyles.popup,
					},
				}}
			>
				{/* Header with month/year and close button */}
				<Box sx={calendarStyles.header}>
					<Box sx={{ width: "16px" }} />
					<Typography sx={calendarStyles.headerTitle}>
						{format(viewDate, "MMMM, yyyy")}
					</Typography>
					<Button
						onClick={handleClose}
						sx={calendarStyles.closeButton}
						size="small"
					>
						×
					</Button>
				</Box>

				{/* Navigation row */}
				<Box sx={calendarStyles.navRow}>
					<Button onClick={handlePrevYear} sx={calendarStyles.navButton}>
						«
					</Button>
					<Button onClick={handlePrevMonth} sx={calendarStyles.navButton}>
						‹
					</Button>
					<Button onClick={handleTodayClick} sx={calendarStyles.todayButton}>
						Today
					</Button>
					<Button onClick={handleNextMonth} sx={calendarStyles.navButton}>
						›
					</Button>
					<Button
						onClick={handleNextYear}
						sx={{
							...calendarStyles.navButton,
							...calendarStyles.navButtonLast,
						}}
					>
						»
					</Button>
				</Box>

				{/* Calendar grid */}
				<Box sx={calendarStyles.calendarGrid}>
					{/* Week header */}
					<Box sx={calendarStyles.weekHeader}>
						<Typography sx={calendarStyles.weekHeaderWk}>wk</Typography>
						<Typography
							sx={{
								...calendarStyles.weekHeaderCell,
								...calendarStyles.weekHeaderCellSunday,
							}}
						>
							Sun
						</Typography>
						<Typography sx={calendarStyles.weekHeaderCell}>Mon</Typography>
						<Typography sx={calendarStyles.weekHeaderCell}>Tue</Typography>
						<Typography sx={calendarStyles.weekHeaderCell}>Wed</Typography>
						<Typography sx={calendarStyles.weekHeaderCell}>Thu</Typography>
						<Typography sx={calendarStyles.weekHeaderCell}>Fri</Typography>
						<Typography sx={calendarStyles.weekHeaderCell}>Sat</Typography>
					</Box>

					{/* Calendar weeks */}
					{calendarWeeks.map((week) => (
						<Box key={week.weekNumber} sx={calendarStyles.weekRow}>
							<Typography sx={calendarStyles.weekNumber}>
								{week.weekNumber}
							</Typography>
							{week.days.map((day) => {
								const isSunday = day.getDay() === 0;
								const isOutsideMonth = !isSameMonth(day, viewDate);
								const isSelected = value && isSameDay(day, value);
								const isTodayDate = isToday(day);
								const isDisabled = isDateDisabled(day);

								return (
									<Box
										key={day.toISOString()}
										onClick={() => !isDisabled && handleDateSelect(day)}
										sx={{
											...calendarStyles.dayCell,
											...(isSunday && calendarStyles.dayCellSunday),
											...(isOutsideMonth && calendarStyles.dayCellOutsideMonth),
											...(isSelected && calendarStyles.dayCellSelected),
											...(isTodayDate && calendarStyles.dayCellToday),
											...(isDisabled && {
												color: "#c0c0c0",
												cursor: "default",
												"&:hover": { backgroundColor: "#ffffff" },
											}),
										}}
									>
										{format(day, "d")}
									</Box>
								);
							})}
						</Box>
					))}
				</Box>

				{/* Select button */}
				<Button
					onClick={() => value && handleClose()}
					sx={calendarStyles.selectButton}
					disabled={!value}
				>
					Select date
				</Button>
			</Popover>
		</Box>
	);
}
