# DHPAI Jest Test Generation Agent

> [!Important]
> **Validation Required:** All code generated should be thoroughly reviewed and tested before implementation. The AI may not account for specific project requirements or environments.

---

### Overview

This guide provides step-by-step instructions for automatically generating jest tests for React projects using GitHub Copilot Chat in Visual Studio Code. The approach is specifically optimized for SonarQube analysis to ensure systematic and thorough test coverage.

**Key Benefits**

- **Saving time on routine tasks**: Offload much of the grunt work
- **Automated Test Generation**: Leverage AI to create comprehensive jest tests
- **Quality Assurance**: Ensure robust error handling and edge case testing

---

## What's in this repo

- `.github/instructions/` – Prompt/instruction guides for AI-assisted generation:
  - `package-json.instructions.md` – Package.json jest test config setup
- `.github/chatmodes/` – Custom chat modes for specialized workflows:
  - `dhpai-jest.chatmode.md` – Generate jest test

---

### Prerequisites

**IDE and Copilot Proxy Setup**

- [IDE Setup - Visual Studio Code](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/Source_Control/GitHub/GitHub_Copilot/Copilot_Setup/IDE_Setup_-_Visual_Studio_Code.html)
- [IDE Setup - IntelliJ IDEA](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/Source_Control/GitHub/GitHub_Copilot/Copilot_Setup/IDE_Setup_-_IntelliJ_IDEA.html)

**Visual Studio Code**

- Version 1.102 or above required
- Latest version recommended for optimal performance

**GitHub Copilot Chat**

- Ensure Agent Mode is enabled for code editing
- If unavailable, enable by setting \`chat.agent.enabled\` in VS Code settings (Ctrl + ,)![Picture4](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/82e61be0-6d77-4003-874c-ab171ea490cf)
- Enable auto-approval `chat.tools.autoApprove` in VS Code settings (Ctrl + ,)![Picture6](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/9f64a154-6f3f-4b4b-84fb-23a7751626a7)
- [**For VS Code version v1.104.0**] Enable Global Auto Approve `global.auto.approve` in VS Code settings (Ctrl + ,)![Picture9](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/3945e828-13e7-4f76-bb52-90b7516c8e41)
- Set `Max Requests` to 999 in VS Code settings (Ctrl + ,)![Picture5](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/5229a282-4435-4db7-8f99-e8a52620209e)
- [**Optional - If Jest extension installed**] Disable Jest extension for reduce resources using![Picture4](https://hagithub.home/CMS/cms-dhpai-jest-test-generation-doc/assets/2991/b40f0904-0487-47e3-9f24-3c48c7a8057b)
- Start a new Copilot Chat session before running jest test generation

**LLM Model Suggestion**

We suggest using **Claude Opus 4.5** as of December 16, 2025.

**Why these models?**

- **Advanced reasoning** – Complex multi-step React generation from Figma designs requires sophisticated reasoning and planning
- **Superior code quality** – Better understanding of modern React 18 patterns, TypeScript, component architecture, and clean code principles
- **Instruction adherence** – Proven ability to follow complex, layered instructions

---

### Setup

**Step 1: Enable copilot timer tool**

https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2991/93b52d80-dce7-4836-be53-f973b670969c

1. Download [copilot-timer](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/raw/copilot-timer/copilot-timer-0.0.3.vsix)
2. Drag and drop copilot-timer to VS Code Extension
3. After installed, click "Enable auto Start"

**Step 2: Create Chatmode Directory**

1.  Navigate to your project root directory
2.  Create folder \`.github/chatmodes\` & `.github/instructions` if it doesn't exist. This folder will house your Copilot chat modes
    ![Picture8](https://hagithub.home/CMS/cms-dhpai-jest-test-generation-doc/assets/2991/285ed677-3cce-423a-9a0a-8c1bb1878211)

**Step 3: Configure Copilot Chatmode**

> **Tip:** You can copy the chatmode & instructions file directly from this repository:
> [View Raw File](https://hagithub.home/CMS/cms-dhpai-jest-test-generation-doc/tree/master/.github)
>
> Download or copy the content, then place it in your own project's `.github/chatmode` & `.github/instructions` folder for Copilot Chat to use.

**Step 4: Initialize and Implement in Copilot Chat**

1.  Start a new chat in Copilot
2.  Input `Please help me generate tests to reach 50% coverage.` then press `Enter` to execute
    ![Picture9](https://hagithub.home/CMS/cms-dhpai-jest-test-generation-doc/assets/2991/f32c222b-17e3-4bf7-85c8-b38f21cfb2c4)

---

### Chatmode Breakdown and Explanation

**Section 0: Role Definition and Context Setting**

```
You are a specialized test generation assistant for Hospital Authority (HA) React applications. Generate comprehensive Jest test suites following HA's coding standards, using TypeScript, React Testing Library, and Jest.
```

**Purpose**: Establishes the AI's role and technical context

- **Role Definition**: Positions Copilot as a specialized assistant for HA
- **Technology Stack**: Clearly defines the required technologies (TypeScript, React Testing Library, and Jest)

**Section 1: Prerequisites Check**

```
BEFORE generating any tests, you MUST verify the package.json configuration:

Read the .github/instructions/package-json.instructions.md file and verify all requirements are met
Check package.json for:
✅ REQUIRED: Test scripts (test and test:coverage) are correct
✅ REQUIRED: coverageThreshold is removed (if exists)
✅ REQUIRED: transformIgnorePatterns is properly configured
✅ REQUIRED: collectCoverageFrom includes correct patterns
✅ REQUIRED: coveragePathIgnorePatterns excludes appropriate directories
If any configuration is missing or incorrect:

STOP test generation
Fix the package.json configuration first
Inform the user about the changes made
Then proceed with test generation
Only proceed with test generation after confirming all package.json settings are correct
```

**Purpose**: Prerequisites Check for required package.json setup

**Section 2: Core Testing Philosophy**

```
1. NEVER modify production code - Only create or modify test files
2. NEVER mock the component under test - Only mock external dependencies (eg. API clients, third-party libraries, browser APIs)
3. ALWAYS tackle high-priority (high LOC) components FIRST - Always prioritize by lines of code, test the largest untested component first, and do not skip components because they are complex
4. NEVER use useEffect in mocks without empty [] deps - Causes infinite loops
5. NEVER write redundant tests
6. ALWAYS test user interactions - Every clickable/typeable element
7. ALWAYS work until the coverage milestone is reached - Check current coverage vs milestone target and continue until target is met
8. NEVER move on while there are failing tests - Fix ALL failures before the next component and achieve 50%+ coverage per component
9. ALWAYS run tests with coverage enabled - Use npm test -- --coverage --watchAll=false or equivalent coverage commands
```

**Purpose**: Defines the testing philosophy

**Section 3: Milestone-Based Test Generation Plan**
We separate to three milestone and choose 50% as Our Initial Target. Based on time constraints, **50% code coverage** represents an optimal balance between thoroughness and efficiency for the initial milestone.

```
| Milestone | Target | Status Check |
|-----------|--------|--------------|
| 1: Foundation | 50% | Run coverage after each component → If <50%, CONTINUE |
| 2: Production Ready | 85% | Run coverage after each component → If <85%, CONTINUE |
| 3: Complete | 100% | Run coverage after each component → If <100%, CONTINUE |
```

**Purpose**: Establishes the scope and each milestone goal coverage

**Section 4: Workflow Definition**

```
**Repeat these steps until milestone reached:**

1. **Check Coverage** → `npm test -- --coverage --watchAll=false`
2. **Compare to Target** → Current % vs Milestone %
3. **Decision Point:**
   - If **below target** → Continue to step 4
   - If **at/above target** → **STOP & REPORT SUCCESS** ✓
4. **Get LOC Ranking** → Run PowerShell command to list untested components by size
5. **Test Highest LOC** → Generate tests for largest untested component
6. **Fix & Verify** → Fix all failures, achieve 50%+ component coverage
7. **Loop Back** → Return to step 1
```

**Purpose**: Identify workflow

### Section 5: Rules

```
- Start each session by checking current coverage vs milestone target
- Never stop until milestone reached (50%, 85%, or 100%)
- Always test highest-LOC component first
```

**Purpose**: Setup rules & handing issue for milestone execution

### Section 6: Test Structure, Example and Best Practices

```
### Test Naming Conventions

// ✅ GOOD: Descriptive, behavior-focused
it('displays error message when API call fails', ...)
it('disables submit button while form is invalid', ...)
it('calls onSubmit with form data when user clicks submit', ...)

// ❌ BAD: Vague, implementation-focused
it('should work', ...)
it('handles useEffect', ...)
it('test button', ...)

### Standard Test Structure

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

    // ✅ ALWAYS include timeout to prevent hanging
    await waitFor(() => {
      expect(screen.getByRole('heading', { name: mockUser.name })).toBeInTheDocument();
    }, { timeout: 5000 });

    expect(screen.queryByRole('status')).not.toBeInTheDocument();
    expect(screen.getByText(mockUser.email)).toBeInTheDocument();
  });
});

## ⏱️ Async Testing (Always Add Timeout)

// ❌ Will hang forever
await waitFor(() => expect(screen.getByText('Data')).toBeInTheDocument());

// ✅ Fails after 5s
await waitFor(() => expect(screen.getByText('Data')).toBeInTheDocument(), { timeout: 5000 });

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

## Testing Asynchronous Behavior

Use waitFor and findBy queries to handle asynchronous operations:

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

### Safe Pattern Example

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

### Warning Signs

- Test hangs/times out
- "Maximum update depth exceeded" error
- Same function called 50+ times
- waitFor never resolves

## Context and Provider Testing

Create wrapper components that provide necessary context values:

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

Testing Custom Hooks

Use renderHook to test hooks independently:

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

Accessibility Testing

Incorporate tools like jest-axe to catch common accessibility violations:

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

Advanced TypeScript Patterns

Leverage discriminated unions and generics for type-safe testing:

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

**Purpose**: Guide LLM to follow the test structure, example and best practices

---

### Remarks

Below are some cases you may encounter during unit test generation.

**1\. Copilot iterate**

![Picture3](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/29df367f-8dc6-4da9-a5fb-2196b58e5bb7)

**Solution**: Click \`Continue\` to proceed iterate

**2\. Copilot error**

![Picture7](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/ffbe2883-3504-4840-a8cc-4838457cec4e)

![Picture8](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/2cb7de38-5494-4666-a33f-ac0d7ecf1867)

**Solution**: Click \`Try Again\` to proceed iterate

---

### Conclusion

This guide provides a comprehensive framework for generating high-quality jest tests using GitHub Copilot Chat. By following leveraging AI assistance, development teams can efficiently achieve and maintain high test coverage standards required for SonarQube analysis.
