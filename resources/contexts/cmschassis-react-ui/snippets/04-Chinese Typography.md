# Chinese Typography

- Note: For HA environment only
- NO configuration is required to use this component.
- Assumption: font HA_MingLiu is already installed in the HA workstation.
- Non-HA workstations will display the content with an alternative font
- `HAMingLiu` font is used

```tsx
import { ChiTypography } from "@cmschassis/react-ui";

export const Default = () => {
  return (
    <div>
      <ChiTypography>中文字</ChiTypography>
    </div>
  );
};
```