# `<DatePicker />`

`DatePicker` is a calendar/date input component from **@cmschassis/react-ui**.  
It supports single date, date+time, and range selection, with custom holiday, disabling, and dropdown year logic.

---

## Props

| Prop                | Type                                 | Description                                                                                  |
|---------------------|--------------------------------------|----------------------------------------------------------------------------------------------|
| `onChange`          | `(date: Date \| null, value: string, event?) => void` | Fired when the value changes.                                                                |
| `isHoliday`         | `(date: Date \| null) => boolean`    | Mark additional days as holidays (besides Sundays).                                          |
| `disablePast`       | `boolean`                            | Disable all past dates.                                                                      |
| `disableFuture`     | `boolean`                            | Disable all future dates.                                                                    |
| `shouldDisableDate` | `(date: Date \| null) => boolean`    | Custom logic to disable specific dates.                                                      |
| `dropdownYearOffset`| `number`                             | Number of years before/after current year in dropdown (default: 5).                          |
| `dropdownYearFrom`  | `number`                             | Start year for dropdown (overrides offset if both set).                                      |
| `dropdownYearTo`    | `number`                             | End year for dropdown (overrides offset if both set).                                        |
| `showTime`          | `boolean`                            | Show time selection.                                                                         |
| `showSeconds`       | `boolean`                            | Show seconds in time selection.                                                              |
| `isAmPm`            | `boolean`                            | Use 12-hour (AM/PM) time format.                                                             |
| `pickerProps`       | `object`                             | Passes props to the underlying picker (e.g. `numberOfMonths`).                               |
| `timeProps`         | `{ timeIntervals?: { hours?: {interval:number, startOdd?:boolean}, minutes?:{interval:number, startOdd?:boolean}, seconds?:{interval:number, startOdd?:boolean} } }` | Customise time step intervals and odd/even start.                                            |
| `label`             | `string`                             | Field label.                                                                                 |
| `helperText`        | `string`                             | Helper text below the field.                                                                 |
| `error`             | `boolean`                            | Error state.                                                                                 |
| `disabled`          | `boolean`                            | Disabled state.                                                                              |
| `fullWidth`         | `boolean`                            | Stretch to fill container.                                                                   |
| `showInternalError` | `boolean`                            | Show internal error messages.                                                                |

---

## Range Selection

Use `<DataRangePicker />` for selecting a date range.

**Key Props:**
- `startDate`, `endDate`: controlled values
- `onStartDateChange`, `onEndDateChange`: change handlers
- `pickerProps`: pass DatePicker props to both pickers
- `startLabel`, `endLabel`: field labels

---

## Features

- **Two months shown by default** (can be changed via `pickerProps.numberOfMonths`)
- **Holiday indication:** Sundays in red, custom holidays via `isHoliday`
- **Disable logic:** `disablePast`, `disableFuture`, `shouldDisableDate`
- **Year dropdown:** Customise with `dropdownYearOffset`, `dropdownYearFrom`, `dropdownYearTo`
- **Time selection:** Enable with `showTime`, `showSeconds`, `isAmPm`, and `timeProps`
- **Form layout:** Supports label, helperText, error, disabled, fullWidth, showInternalError

---

## Quick Example

```tsx
<DatePicker
  onChange={(date, value) => console.log(date, value)}
  isHoliday={date => /* your logic */}
  disablePast
  shouldDisableDate={date => date?.getDay() === 4}
  dropdownYearOffset={5}
  showTime
  showSeconds
  isAmPm
  pickerProps={{ numberOfMonths: 1 }}
  timeProps={{
    timeIntervals: {
      hours: { interval: 2, startOdd: true },
      minutes: { interval: 5 },
      seconds: { interval: 10, startOdd: true },
    }
  }}
  label="Start Date"
  helperText="Click calendar icon to enter start date."
  fullWidth
/>
```

**Range:**
```tsx
<DataRangePicker
  startDate={start}
  onStartDateChange={setStart}
  endDate={end}
  onEndDateChange={setEnd}
  pickerProps={{ fullWidth: true }}
  startLabel="Start Date"
  endLabel="End Date"
/>
```
