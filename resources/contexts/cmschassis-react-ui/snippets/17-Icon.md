## Icon Set

```tsx
import {
  Add,
  Delete,
  Detail,
  DrugIngredientSearch,
  Edit,
  FileExcel,
  FileImage,
  FilePdf,
  FileUnknown,
  FileWord,
  Log,
  Preview,
  Print,
  Reload,
} from "@cmschassis/react-ui";

export const Default = () => {
  return (
    <div>
      <FileExcel />
      <FileWord />
      <FilePdf />
      <FileImage />
      <FileUnknown />
      <Add />
      <Delete />
      <Edit />
      <Reload />
      <Print />
      <Preview />
      <Log />
      <DrugIngredientSearch />
      <Detail />
    </div>
  );
};
```

## Color And Size

```tsx
import {
  Add,
  Delete,
  Detail,
  DrugIngredientSearch,
  Edit,
  FileExcel,
  FileImage,
  FilePdf,
  FileUnknown,
  FileWord,
  Log,
  Preview,
  Print,
  Reload,
} from "@cmschassis/react-ui";
import { Stack, Typography } from "@mui/material";

type Color =
  | "inherit"
  | "primary"
  | "secondary"
  | "action"
  | "disabled"
  | "error";
type FontSize = undefined | "inherit" | "large" | "medium" | "small";

const colors: Color[] = ["primary", "secondary", "error", "disabled"];
const fontSizes: FontSize[] = ["small", "medium", "large"];

export const ColorAndSize = () => {
  return (
    <Stack spacing={10}>
      {colors.map((c) => (
        <Stack key={c}>
          <Typography variant="h6" sx={{ textTransform: "capitalize" }}>
            {c}
          </Typography>
          <Stack>
            {fontSizes.map((s) => (
              <div key={`${c}-${s}`}>
                <FileExcel color={c} fontSize={s} />
                <FileWord color={c} fontSize={s} />
                <FilePdf color={c} fontSize={s} />
                <FileImage color={c} fontSize={s} />
                <FileUnknown color={c} fontSize={s} />
                <Add color={c} fontSize={s} />
                <Delete color={c} fontSize={s} />
                <Edit color={c} fontSize={s} />
                <Reload color={c} fontSize={s} />
                <Print color={c} fontSize={s} />
                <Preview color={c} fontSize={s} />
                <Log color={c} fontSize={s} />
                <DrugIngredientSearch color={c} fontSize={s} />
                <Detail color={c} fontSize={s} />
              </div>
            ))}
          </Stack>
        </Stack>
      ))}
    </Stack>
  );
};
```