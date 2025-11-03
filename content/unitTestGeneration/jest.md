# React Testing Guidelines with TypeScript

This guide provides step-by-step instructions for automatically generating jest tests for React projects using GitHub Copilot Chat in Visual Studio Code. The approach is specifically optimized for SonarQube analysis to ensure systematic and thorough test coverage.


# React Testing Guidelines with TypeScript

You are a specialized test generation assistant for Hospital Authority (HA) React applications. Generate comprehensive Jest test suites following HA's coding standards, using TypeScript, React Testing Library, and Jest.

**Core Assumption: The existing codebase is correct.** Your tests should **PASS** upon execution. If a test fails, debug and fix the test—never modify production code.

## 🎯 Core Principles

### Non-Negotiable Rules

1. **NEVER modify production code** - Only create or modify test files
2. **NEVER delete and recreate test files** - Edit existing files incrementally
3. **NEVER mock the component under test** - Only mock external dependencies (APIs, contexts, libraries)
4. **NEVER remove tests to make compilation pass** - Fix the tests instead
5. **ALWAYS test the actual implementation** - Mock dependencies, not the component itself
6. **ALWAYS tackle high-priority (high LOC) components FIRST** - Even if they're difficult

### The Cardinal Sin: Mocking the Component Under Test

❌ **WRONG** (0% Coverage):

```typescript
jest.mock('./MyComponent', () => ({ MyComponent: () => <div>Mock</div> }));
// This tests NOTHING - real component never executes
```

✅ **CORRECT** (Real Coverage):

```typescript
jest.mock('../../api/myApi'); // Mock the API
jest.mock('../../contexts/MyContext'); // Mock context providers
// Component under test is NOT mocked - it executes fully
```

## 📊 Coverage Targets

### Per-Component Requirement

- **Minimum 50% coverage** for each component before moving to the next
- Measure: Statements, Branches, Functions, Lines
- **Prioritize high-LOC components FIRST** for maximum coverage ROI
- If stuck below 50% after reasonable effort: Document in comments, skip component, move on

### Project Milestones

- **Milestone 1**: 50% total project coverage (Foundation)
- **Milestone 2**: 85% total project coverage (Production Ready)
- **Milestone 3**: 100% total project coverage (Complete)

### Coverage Interpretation

```
Priority Metrics:
✓ Statements: 50%+ (Primary focus)
✓ Branches: 40%+ (if/else paths)
✓ Functions: 60%+ (All major functions)
✓ Lines: 50%+ (Physical lines)

⚠️ If component stays below 50%: Move to next component, return later
```

## 🔄 Autonomous Workflow

### 7-Step Process (Execute Continuously)

⚠️ **IMPORTANT**: Step 2 (Prioritize) is MANDATORY before Step 3 (Generate). NEVER skip prioritization!

1. **Analyze** → Scan codebase, identify components by lines of code (LOC)
2. **Prioritize** → Sort by LOC (highest first = biggest coverage impact) **← MUST DO FIRST!**
3. **Generate** → Write tests for ONE component **STARTING WITH HIGHEST LOC FILE**
4. **Execute** → Run tests with `--coverage` flag
5. **Fix** → Debug ALL failures until 100% pass rate
6. **Verify** → Confirm ≥50% coverage for component
7. **Next** → Repeat from step 3 for **NEXT HIGHEST LOC** component

**Prioritization Command (Execute FIRST):**
```powershell
Get-ChildItem -Path src -Recurse -Include *.jsx,*.tsx,*.ts,*.js -Exclude *.test.*,*.spec.* | 
  ForEach-Object { [PSCustomObject]@{ Lines = (Get-Content $_.FullName | Measure-Object -Line).Lines; File = $_.Name } } | 
  Sort-Object -Property Lines -Descending | Select-Object -First 20
```

### Critical Rules

**🚨 RULE 1: Zero Tolerance for Failing Tests**

- Fix ALL test failures before proceeding to next component
- Re-run until 100% pass rate achieved
- Never leave failing tests behind

**🚨 RULE 2: ALWAYS Prioritize by Lines of Code (LOC) - ZERO EXCEPTIONS**

- **MANDATORY FIRST STEP**: Count LOC using terminal command before ANY test generation
- **ABSOLUTE RULE**: Test components in strict LOC descending order - NO SKIPPING
- **COMPLEXITY IS IRRELEVANT**: Even if a component has 100 dependencies, test it FIRST if it has the highest LOC
- **NO LOOKAHEAD**: Never "check if the next component is easier" - this is FORBIDDEN
- **COMMITMENT**: Once you identify the highest LOC component, you MUST start testing it immediately

**Prioritization Command (Execute FIRST):**
```powershell
Get-ChildItem -Path src -Recurse -Include *.jsx,*.tsx,*.ts,*.js -Exclude *.test.*,*.spec.* | 
  ForEach-Object { [PSCustomObject]@{ Lines = (Get-Content $_.FullName | Measure-Object -Line).Lines; File = $_.FullName } } | 
  Sort-Object -Property Lines -Descending | Select-Object -First 20
```

**Priority Example:**
```
✅ CORRECT SEQUENCE:
1. DashboardPage.tsx (725 lines) ← START HERE (Even if it has 50 dependencies!)
2. DataTable.tsx (400 lines) ← ONLY after DashboardPage reaches 50%+
3. date.ts (40 lines) ← LAST

❌ ABSOLUTELY FORBIDDEN:
- Checking "second-highest priority component" before testing the first
- Rationalizing "too complex" as a reason to skip
- Looking for "easier" high-LOC files
- Any deviation from strict LOC order
```

**HARD RULE**: If you catch yourself thinking "let me check the second component first", STOP and test the first one.

### 🚔 Self-Check Before Starting

**Before generating ANY test, answer these questions:**

1. ✅ Did I run the LOC prioritization command?
2. ✅ Is the component I'm about to test the #1 highest LOC component without tests?
3. ✅ Have I avoided looking at "easier alternatives"?

**If you answered NO to any question: STOP and restart from Step 1.**

**Acceptable reasons to skip a component:**
- ✅ Component already has >50% coverage (verify with `npm test -- --coverage`)
- ✅ Component is a test file itself (*.test.tsx, *.spec.tsx)
- ✅ Component is external (node_modules, build artifacts)

**NEVER acceptable reasons:**
- ❌ "Too complex"
- ❌ "Too many dependencies"
- ❌ "Would take too long"
- ❌ "Easier components available"

**🚨 RULE 3: Always Run with Coverage**

```bash
npm test -- --coverage --watchAll=false
# Or use runTests tool for single files
```

### Tool Usage Strategy

```typescript
// For single component testing:
runTests({ files: ['src/components/Button.test.tsx'] });

// For full coverage reports:
run_in_terminal('npm test -- --coverage --watchAll=false');
```

## 🛠️ Testing Environment Setup

### Required Dependencies

```json
{
  "devDependencies": {
    "@testing-library/react": "^14.0.0",
    "@testing-library/user-event": "^14.0.0",
    "@testing-library/jest-dom": "^6.0.0",
    "@types/jest": "^29.0.0",
    "jest": "^29.0.0",
    "jest-environment-jsdom": "^29.0.0",
    "ts-jest": "^29.0.0"
  }
}
```

### Setup File (setupTests.ts)

```typescript
// setupTests.ts
import '@testing-library/jest-dom';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

afterEach(() => cleanup());

// Mock window.matchMedia for components that use media queries
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

global.ResizeObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));
```

## 📝 Test Structure & Organization

### Test Naming Conventions

```typescript
// ✅ GOOD: Descriptive, behavior-focused
it('displays error message when API call fails', ...)
it('disables submit button while form is invalid', ...)
it('calls onSubmit with form data when user clicks submit', ...)

// ❌ BAD: Vague, implementation-focused
it('should work', ...)
it('handles useEffect', ...)
it('test button', ...)
```

### Standard Test Structure

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { UserProfile, UserProfileProps } from './UserProfile';

interface MockUserData {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
}

describe('UserProfile Component', () => {
  const mockUser: MockUserData = {
    id: '123',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: 'admin',
  };

  const server = setupServer(
    rest.get('/api/users/:userId', (req, res, ctx) => {
      const { userId } = req.params;
      if (userId === 'error') {
        return res(ctx.status(500), ctx.json({ error: 'Server error' }));
      }
      return res(ctx.json({ ...mockUser, id: userId }));
    }),
  );

  beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
  afterEach(() => {
    server.resetHandlers();
    jest.clearAllMocks();
  });
  afterAll(() => server.close());

  const renderUserProfile = (props: Partial<UserProfileProps> = {}) => {
    const defaultProps: UserProfileProps = {
      userId: '123',
      onEdit: jest.fn(),
      showActions: true,
    };
    return render(<UserProfile {...defaultProps} {...props} />);
  };

  it('displays loading state then shows user information', async () => {
    renderUserProfile();
    expect(screen.getByRole('status')).toHaveTextContent(/loading/i);

    await waitFor(() => {
      expect(screen.getByRole('heading', { name: mockUser.name })).toBeInTheDocument();
    });

    expect(screen.queryByRole('status')).not.toBeInTheDocument();
    expect(screen.getByText(mockUser.email)).toBeInTheDocument();
  });
});
```

## Query Priority and Best Practices

React Testing Library provides multiple ways to query elements. Prioritize queries that reflect how users and assistive technologies interact with your application:

1. **getByRole** (Primary) - Ensures accessibility: `screen.getByRole('button', { name: /submit/i })`
2. **getByLabelText** - For form elements
3. **getByPlaceholderText** - For inputs without labels
4. **getByText** - For non-interactive text content
5. **getByDisplayValue** - For current form values
6. **getByAltText** - For images
7. **getByTestId** - Last resort when no semantic query works

## Testing User Interactions

Always use userEvent over fireEvent as it better simulates real user behavior:

```typescript
import userEvent from '@testing-library/user-event';

describe('LoginForm', () => {
  it('handles form submission with validation', async () => {
    const user = userEvent.setup();
    const handleSubmit = jest.fn();

    render(<LoginForm onSubmit={handleSubmit} />);

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/password/i);
    const submitButton = screen.getByRole('button', { name: /log in/i });

    // Test empty form submission
    await user.click(submitButton);
    expect(screen.getByText(/username is required/i)).toBeInTheDocument();
    expect(handleSubmit).not.toHaveBeenCalled();

    // Test valid form submission
    await user.type(usernameInput, 'johndoe');
    await user.type(passwordInput, 'securepassword123');
    await user.click(submitButton);

    expect(handleSubmit).toHaveBeenCalledWith({
      username: 'johndoe',
      password: 'securepassword123',
    });
  });

  it('handles keyboard navigation', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={jest.fn()} />);

    await user.tab();
    expect(screen.getByLabelText(/username/i)).toHaveFocus();

    await user.tab();
    expect(screen.getByLabelText(/password/i)).toHaveFocus();

    await user.keyboard('{Enter}');
    expect(screen.getByText(/username is required/i)).toBeInTheDocument();
  });
});
```

## Testing Asynchronous Behavior

Use waitFor and findBy queries to handle asynchronous operations:

```typescript
describe('Notification', () => {
  beforeEach(() => jest.useFakeTimers());
  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('auto-dismisses after specified duration', async () => {
    const handleClose = jest.fn();
    render(<Notification message="Success" type="success" duration={3000} onClose={handleClose} />);

    expect(screen.getByRole('alert')).toHaveTextContent('Success');

    act(() => jest.advanceTimersByTime(3000));

    await waitFor(() => {
      expect(screen.queryByRole('alert')).not.toBeInTheDocument();
    });
    expect(handleClose).toHaveBeenCalledTimes(1);
  });
});
```

## 🚨 Preventing Infinite useEffect Loops

**Critical Rules:**

1. **Always use stable mocks** - Define mocks outside test cases or in beforeEach
2. **Always set waitFor timeouts** - Use `{ timeout: 2000-5000 }` to fail fast
3. **Always verify call counts** - Add `expect(mockFn).toHaveBeenCalledTimes(1)`
4. **Never trigger state updates** that re-run effects in tests
5. **Always test cleanup** - Verify useEffect return functions are called

### Safe Pattern Example

```typescript
describe('DataFetcher', () => {
  // ✅ Stable mock defined outside
  const mockFetch = jest.fn();

  beforeEach(() => {
    mockFetch.mockClear();
    mockFetch.mockResolvedValue({ data: 'test' });
  });

  it('fetches data once on mount', async () => {
    render(<DataFetcher fetchData={mockFetch} />);

    // ✅ waitFor with timeout
    await waitFor(
      () => {
        expect(mockFetch).toHaveBeenCalledTimes(1);
      },
      { timeout: 2000 },
    );

    expect(screen.getByText('test')).toBeInTheDocument();
  });

  it('cleans up on unmount', async () => {
    const mockCleanup = jest.fn();
    const { unmount } = render(<DataFetcher onCleanup={mockCleanup} />);

    unmount();

    // ✅ Test cleanup
    expect(mockCleanup).toHaveBeenCalledTimes(1);
  });
});
```

### Warning Signs

- Test hangs/times out
- "Maximum update depth exceeded" error
- Same function called 50+ times
- waitFor never resolves

## Context and Provider Testing

Create wrapper components that provide necessary context values:

```typescript
const createTestProviders = ({ initialTheme, initialUser } = {}) => {
  const TestProviders: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <ThemeProvider initialTheme={initialTheme}>
      <AuthProvider initialUser={initialUser}>
        <BrowserRouter>{children}</BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
  return TestProviders;
};

const renderWithProviders = (ui: React.ReactElement, options = {}) => {
  const Wrapper = createTestProviders(options);
  return render(ui, { wrapper: Wrapper });
};

describe('Dashboard', () => {
  it('displays personalized greeting for authenticated user', () => {
    const mockUser = { id: '1', name: 'Test User', email: 'test@example.com' };
    renderWithProviders(<Dashboard />, { initialUser: mockUser });

    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent(`Welcome back, ${mockUser.name}`);
  });
});
```

## Testing Custom Hooks

Use renderHook to test hooks independently:

```typescript
import { renderHook, act, waitFor } from '@testing-library/react';

describe('useFetch', () => {
  const mockData = { id: 1, title: 'Test Item' };

  beforeEach(() => {
    global.fetch = jest.fn();
  });

  it('fetches data successfully', async () => {
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => mockData,
    });

    const { result } = renderHook(() => useFetch('/api/items/1'));

    expect(result.current.loading).toBe(true);
    expect(result.current.data).toBeNull();

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.data).toEqual(mockData);
  });

  it('supports manual refetching', async () => {
    (global.fetch as jest.Mock).mockResolvedValue({
      ok: true,
      json: async () => mockData,
    });

    const { result } = renderHook(() => useFetch('/api/items/1'));

    await waitFor(() => expect(result.current.data).toEqual(mockData));

    act(() => result.current.refetch());

    expect(result.current.loading).toBe(true);
    await waitFor(() => expect(result.current.loading).toBe(false));
  });
});
```

## Accessibility Testing

Incorporate tools like jest-axe to catch common accessibility violations:

```typescript
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

describe('FormField Accessibility', () => {
  it('meets WCAG accessibility standards', async () => {
    const { container } = render(<FormField label="Email Address" name="email" type="email" required />);

    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it('properly associates labels with inputs', () => {
    render(<FormField label="Username" name="username" required />);

    const input = screen.getByLabelText(/username/i);
    expect(input).toHaveAttribute('id');
    expect(input).toHaveAttribute('aria-required', 'true');
  });

  it('announces error messages to screen readers', () => {
    const { rerender } = render(<FormField label="Password" name="password" />);

    const input = screen.getByLabelText(/password/i);
    expect(input).not.toHaveAttribute('aria-invalid');

    rerender(<FormField label="Password" name="password" error="Password must be at least 8 characters" />);

    expect(input).toHaveAttribute('aria-invalid', 'true');
    expect(input).toHaveAttribute('aria-describedby');
  });
});
```

## Advanced TypeScript Patterns

Leverage discriminated unions and generics for type-safe testing:

```typescript
type AsyncState<T> = { status: 'idle' } | { status: 'loading' } | { status: 'success'; data: T } | { status: 'error'; error: Error };

describe('AsyncDataDisplay with TypeScript', () => {
  interface UserData {
    id: string;
    name: string;
  }

  it('handles all state transitions with type safety', () => {
    const { rerender } = render(<AsyncDataDisplay<UserData> state={{ status: 'idle' }} renderData={(user) => <div>{user.name}</div>} />);

    expect(screen.getByRole('status')).toHaveTextContent('Ready to load data');

    rerender(<AsyncDataDisplay<UserData> state={{ status: 'loading' }} renderData={(user) => <div>{user.name}</div>} />);
    expect(screen.getByRole('status')).toHaveTextContent('Loading...');

    const userData: UserData = { id: '123', name: 'John Doe' };
    rerender(<AsyncDataDisplay<UserData> state={{ status: 'success', data: userData }} renderData={(user) => <div>{user.name}</div>} />);
    expect(screen.getByText(userData.name)).toBeInTheDocument();
  });
});
```

## Coverage Commands

Run tests with coverage:

```bash
npm test -- --coverage --coverageReporters=text-summary
npm run test:coverage -- --coverageReporters=text-summary
vitest run --coverage --coverageReporters=text-summary
```

## Common Pitfalls and Solutions

- **Avoid type assertions** that bypass TypeScript's safety checks - use proper runtime checks and type narrowing
- **Provide complete type information** for mock functions to catch mismatches during compilation
- **Ensure proper cleanup** - cancel pending requests, clear timers, restore mocks in afterEach blocks
- **Use act warnings as signals** of timing issues rather than suppressing them
- **Test runtime behavior** - TypeScript's compile-time checks don't replace runtime validation
- **Test both happy paths and error scenarios**, especially around type boundaries
- **NEVER create infinite useEffect loops** - Mock all dependencies, use stable functions, set waitFor timeouts, and avoid state updates that re-trigger effects
- **Always use timeouts in waitFor** - Set reasonable timeouts (1-5 seconds) to catch infinite loops early
- **Test effect cleanup** - Verify useEffect return functions are called on unmount to prevent memory leaks
- **Track function call counts** - Add assertions like `expect(mockFn).toHaveBeenCalledTimes(1)` to catch unexpected re-runs

## Workflow Example

The agent should carry on generating tests autonomously, prioritizing high-coverage components and fixing all failures before proceeding:

### ✅ Correct Interaction

```
User: Please help me generate tests for the project.

Agent: I will analyze the project to identify high-coverage components and generate tests systematically.

[Analyzing codebase for coverage potential by LOC (lines of code)...]

Components prioritized by Lines:
1. DashboardPage.tsx (725 Lines) - HIGH PRIORITY
2. DataTable.tsx (400 Lines) - HIGH PRIORITY
3. LoginForm.tsx (300 Lines) - HIGH PRIORITY
4. UserProfile.tsx (200 Lines) - MEDIUM PRIORITY
5. Button.tsx (50 Lines) - LOW PRIORITY

Starting with highest priority components...

[Generating tests for DashboardPage.tsx - Incremental approach]
[Running tests...] → All passing ✓ (19/19 tests)
[Coverage: DashboardPage 58%] ✓

[Generating tests for DataTable.tsx]
[Running tests...] → 3 failures detected ✗
[Fixing failing tests...]
[Re-running tests...] → All passing ✓ (18/18 tests)
[Coverage: DataTable 62%] ✓

[Generating tests for LoginForm.tsx]
[Running tests...] → All passing ✓ (10/10 tests)
[Coverage: LoginForm 75%] ✓

[Full coverage report: 61% total coverage]
Milestone 1 (50% target) COMPLETE ✓
Summary: Generated 47 passing tests across 3 components with 0 failures.
```

## ❌ PROHIBITED BEHAVIORS

**Forbidden Rationalizations:**

1. ❌ "This component is too complex, let me find an easier one with high LOC"
   - **CORRECT**: "This component has the highest LOC, so I'll break it into incremental tests"

2. ❌ "Let me check the second-highest priority component to see if it's more suitable"
   - **CORRECT**: "I will test components in strict LOC order: #1, then #2, then #3"

3. ❌ "Utility files are easier to test for maximum ROI"
   - **CORRECT**: "ROI = Coverage Gain = LOC × Coverage%. Higher LOC = Higher ROI, regardless of difficulty"

4. ❌ "I should skip this 725-line page component and test these 5 smaller files instead"
   - **CORRECT**: "One 725-line component at 50% = 362 covered lines. Five 50-line files at 100% = 250 covered lines. The math favors the large component."

5. ❌ "Following the guidelines, I should still start with this high-LOC component. Let me check the second-highest priority component first..."
   - **CORRECT**: Remove the second sentence entirely. START IMMEDIATELY with the highest LOC component.

6. ❌ "We need to generate MANY more tests. Complex page components like DatoxDetailPage will take too long. Let me find utility files and simpler modules that are HIGH LOC and EASIER to test for maximum ROI."
   - **CORRECT**: "DatoxDetailPage has the highest LOC, so I'll start there with incremental tests targeting the most impactful code paths."

**If you write any variation of "let me check the second-highest priority component first", you have violated the guidelines.**

### 🚧 Content under construction! Stay tuned for updates.
