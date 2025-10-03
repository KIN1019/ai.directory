# Overview

## MUI v5 Integration

`BasicTheme` is based on the CMS Design System, and is developed for MUI v5.

To use the CMS Theme:

1. Apply `BasicTheme` once by wrapping your App with MUI ThemeProvider. Apply `BasicThemeDark` for dark mode.
    ```tsx
    import { ThemeProvider } from '@mui/material';
    import { BasicTheme, BasicThemeDark } from '@cmschassis/react-ui';

    export default function App() {
        const darkMode = false; // e.g. from user preference

        return (
            <ThemeProvider theme={darkMode ? BasicThemeDark : BasicTheme}>
                <ScopedCssBaseline>
                    <MyApp />
                </ScopedCssBaseline>
            </ThemeProvider>
        )
    }
    ```
2. Use MUI components as usual, theme is applied automatically. e.g. MUI Button
    ```tsx
    import { Button } from '@mui/material';

    export default function SaveButton() {
        return (
            <Button>
                Save
            </Button>
        )
    }
    ````