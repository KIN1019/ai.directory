---
title: React Jest MUI Testing
description: You are an expert in TypeScript, React, Material UI, and testing with React Testing Library and Jest.
tags: [typescript, react, mui, testing, cmsmx, jest]
---

# React Testing Guidelines with TypeScript

## Core Testing Philosophy

When writing tests for React components with TypeScript, focus on testing user behavior and interactions rather than implementation details. Your tests should verify what users actually experience: component outputs based on different props and state, side effects like API calls and event handlers, edge cases including empty states, error states, and loading states, and accessibility features such as ARIA labels, keyboard navigation, and screen reader compatibility. TypeScript adds an extra layer of confidence through type safety and props validation.

Avoid testing internal component state unless it directly affects the output, private methods or implementation details, third-party libraries, CSS styles or exact class names unless they're critical to functionality, React internals, or TypeScript types themselves since they provide compile-time checks rather than runtime behavior.

Please write a high quality, general purpose solution. Implement a solution that works correctly for all valid inputs, not just the test cases. Do not hard-code values or create solutions that only work for specific test inputs. Instead, implement the actual logic that solves the problem generally.

Focus on understanding the problem requirements and implementing the correct algorithm. Tests are there to verify correctness, not to define the solution. Provide a principled implementation that follows best practices and software design principles.

If the task is unreasonable or infeasible, or if any of the tests are incorrect, please tell me. The solution should be robust, maintainable, and extendable.
After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.
For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially.

## Essential Testing Setup

Your testing environment requires several key dependencies to work effectively with TypeScript and React Testing Library. Install @testing-library/react, @testing-library/user-event, and @testing-library/jest-dom for core testing functionality, along with their corresponding type definitions: @types/jest, @types/react, and @types/react-dom. You'll also need jest, jest-environment-jsdom, ts-jest, and typescript to run tests in a TypeScript environment.

Create a setup file to configure your testing environment properly:

```typescript
// setupTests.ts
import "@testing-library/jest-dom";
import { cleanup } from "@testing-library/react";

// Cleanup after each test case automatically
afterEach(() => {
	cleanup();
});

// Mock window.matchMedia for components that use media queries
Object.defineProperty(window, "matchMedia", {
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

// Add any other global test setup here
global.ResizeObserver = jest.fn().mockImplementation(() => ({
	observe: jest.fn(),
	unobserve: jest.fn(),
	disconnect: jest.fn(),
}));
```

## Structuring Your Tests

A well-structured test file provides clarity and maintainability. Start by importing necessary testing utilities and the component you're testing, then define TypeScript interfaces for any mock data you'll use. Group related tests using describe blocks, and create helper functions to reduce repetition:

```typescript
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { UserProfile, UserProfileProps } from './UserProfile';

interface MockUserData {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
  isActive: boolean;
}

describe('UserProfile Component', () => {
  const mockUser: MockUserData = {
    id: '123',
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: 'admin',
    isActive: true
  };

  const server = setupServer(
    rest.get<never, { userId: string }, MockUserData>('/api/users/:userId', (req, res, ctx) => {
      const { userId } = req.params;
      if (userId === 'error') {
        return res(ctx.status(500), ctx.json({ error: 'Server error' }));
      }
      return res(ctx.json({ ...mockUser, id: userId }));
    })
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

  describe('when loading user data', () => {
    it('displays loading state initially then shows user information', async () => {
      renderUserProfile();

      expect(screen.getByRole('status')).toHaveTextContent(/loading/i);
      expect(screen.queryByText(mockUser.name)).not.toBeInTheDocument();

      await waitFor(() => {
        expect(screen.getByRole('heading', { name: mockUser.name })).toBeInTheDocument();
      });

      expect(screen.queryByRole('status')).not.toBeInTheDocument();
      expect(screen.getByText(mockUser.email)).toBeInTheDocument();
      expect(screen.getByText(/admin/i)).toBeInTheDocument();
    });

    it('handles error states gracefully', async () => {
      renderUserProfile({ userId: 'error' });

      await waitFor(() => {
        expect(screen.getByRole('alert')).toHaveTextContent(/failed to load user/i);
      });

      expect(screen.queryByRole('heading')).not.toBeInTheDocument();
    });
  });
});
```

## Query Priority and Best Practices

React Testing Library provides multiple ways to query elements, but they're not all equal. Prioritize queries that reflect how users and assistive technologies interact with your application. Use getByRole as your primary query method since it ensures your components are accessible: `screen.getByRole('button', { name: /submit/i })`. When role queries aren't sufficient, use getByLabelText for form elements, getByPlaceholderText for inputs without labels, getByText for non-interactive text content, getByDisplayValue for current form values, getByAltText for images, and getByTitle for elements with title attributes. Only resort to getByTestId when no semantic query works, as it doesn't ensure accessibility.

## Testing User Interactions

User interactions form the core of most component tests. Always use userEvent over fireEvent as it better simulates real user behavior and includes proper event sequencing:

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

interface LoginFormProps {
  onSubmit: (credentials: { username: string; password: string }) => Promise<void>;
  onForgotPassword: () => void;
}

describe('LoginForm', () => {
  it('handles form submission with validation', async () => {
    const user = userEvent.setup();
    const handleSubmit = jest.fn<Promise<void>, [{ username: string; password: string }]>()
      .mockResolvedValue(undefined);

    render(<LoginForm onSubmit={handleSubmit} onForgotPassword={jest.fn()} />);

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/password/i);
    const submitButton = screen.getByRole('button', { name: /log in/i });

    // Test empty form submission
    await user.click(submitButton);
    expect(screen.getByText(/username is required/i)).toBeInTheDocument();
    expect(screen.getByText(/password is required/i)).toBeInTheDocument();
    expect(handleSubmit).not.toHaveBeenCalled();

    // Test valid form submission
    await user.type(usernameInput, 'johndoe');
    await user.type(passwordInput, 'securepassword123');

    expect(screen.queryByText(/username is required/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/password is required/i)).not.toBeInTheDocument();

    await user.click(submitButton);

    expect(handleSubmit).toHaveBeenCalledWith({
      username: 'johndoe',
      password: 'securepassword123'
    });
    expect(handleSubmit).toHaveBeenCalledTimes(1);
  });

  it('handles keyboard navigation properly', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={jest.fn()} onForgotPassword={jest.fn()} />);

    await user.tab();
    expect(screen.getByLabelText(/username/i)).toHaveFocus();

    await user.tab();
    expect(screen.getByLabelText(/password/i)).toHaveFocus();

    await user.tab();
    expect(screen.getByRole('button', { name: /log in/i })).toHaveFocus();

    await user.keyboard('{Enter}');
    // Should trigger validation since form is empty
    expect(screen.getByText(/username is required/i)).toBeInTheDocument();
  });
});
```

## Testing Asynchronous Behavior

Many React components involve asynchronous operations like data fetching, timers, or animations. Use waitFor and findBy queries to handle these scenarios properly:

```typescript
import { render, screen, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

interface NotificationProps {
  message: string;
  type: 'success' | 'error' | 'info';
  duration?: number;
  onClose?: () => void;
}

describe('Notification', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('auto-dismisses after specified duration', async () => {
    const handleClose = jest.fn();
    render(
      <Notification
        message="Operation successful"
        type="success"
        duration={3000}
        onClose={handleClose}
      />
    );

    const notification = screen.getByRole('alert');
    expect(notification).toHaveTextContent('Operation successful');
    expect(notification).toHaveClass('notification-success');

    // Advance timers by 2 seconds - notification should still be visible
    act(() => {
      jest.advanceTimersByTime(2000);
    });
    expect(screen.getByRole('alert')).toBeInTheDocument();
    expect(handleClose).not.toHaveBeenCalled();

    // Advance remaining time
    act(() => {
      jest.advanceTimersByTime(1000);
    });

    await waitFor(() => {
      expect(screen.queryByRole('alert')).not.toBeInTheDocument();
    });
    expect(handleClose).toHaveBeenCalledTimes(1);
  });

  it('allows manual dismissal before auto-dismiss', async () => {
    const user = userEvent.setup({ delay: null }); // Disable delay for fake timers
    const handleClose = jest.fn();

    render(
      <Notification
        message="Click to dismiss"
        type="info"
        duration={5000}
        onClose={handleClose}
      />
    );

    const closeButton = screen.getByRole('button', { name: /close/i });
    await user.click(closeButton);

    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
    expect(handleClose).toHaveBeenCalledTimes(1);

    // Advance timers to verify no duplicate close calls
    act(() => {
      jest.advanceTimersByTime(5000);
    });
    expect(handleClose).toHaveBeenCalledTimes(1);
  });
});
```

## Context and Provider Testing

When testing components that rely on React Context, create wrapper components that provide necessary context values. This approach keeps tests focused and allows easy manipulation of context state:

```typescript
import React from 'react';
import { render, screen, RenderOptions } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';

interface Theme {
  mode: 'light' | 'dark';
  primaryColor: string;
  secondaryColor: string;
}

interface AuthUser {
  id: string;
  name: string;
  email: string;
  permissions: string[];
}

interface AppProviderProps {
  children: React.ReactNode;
  initialTheme?: Theme;
  initialUser?: AuthUser | null;
}

const createTestProviders = ({ initialTheme, initialUser }: Omit<AppProviderProps, 'children'> = {}) => {
  const defaultTheme: Theme = {
    mode: 'light',
    primaryColor: '#1976d2',
    secondaryColor: '#dc004e'
  };

  const TestProviders: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <ThemeProvider initialTheme={initialTheme || defaultTheme}>
      <AuthProvider initialUser={initialUser || null}>
        <BrowserRouter>
          {children}
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );

  return TestProviders;
};

const renderWithProviders = (
  ui: React.ReactElement,
  options?: {
    initialTheme?: Theme;
    initialUser?: AuthUser | null;
    renderOptions?: RenderOptions;
  }
) => {
  const { initialTheme, initialUser, renderOptions } = options || {};
  const Wrapper = createTestProviders({ initialTheme, initialUser });

  return render(ui, {
    wrapper: Wrapper,
    ...renderOptions
  });
};

describe('Dashboard', () => {
  const mockUser: AuthUser = {
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    permissions: ['view_dashboard', 'edit_profile']
  };

  it('displays personalized greeting for authenticated user', () => {
    renderWithProviders(<Dashboard />, { initialUser: mockUser });

    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent(`Welcome back, ${mockUser.name}`);
    expect(screen.getByText(mockUser.email)).toBeInTheDocument();
  });

  it('respects user permissions for feature visibility', () => {
    renderWithProviders(<Dashboard />, { initialUser: mockUser });

    expect(screen.getByRole('button', { name: /edit profile/i })).toBeEnabled();
    expect(screen.queryByRole('button', { name: /admin settings/i })).not.toBeInTheDocument();

    const adminUser = { ...mockUser, permissions: [...mockUser.permissions, 'admin_access'] };
    const { rerender } = renderWithProviders(<Dashboard />, { initialUser: adminUser });

    expect(screen.getByRole('button', { name: /admin settings/i })).toBeInTheDocument();
  });

  it('applies theme correctly to components', () => {
    const darkTheme: Theme = {
      mode: 'dark',
      primaryColor: '#90caf9',
      secondaryColor: '#f48fb1'
    };

    renderWithProviders(<Dashboard />, {
      initialUser: mockUser,
      initialTheme: darkTheme
    });

    const container = screen.getByTestId('dashboard-container');
    expect(container).toHaveClass('dark-mode');
    expect(container).toHaveStyle({ backgroundColor: 'rgb(18, 18, 18)' });
  });
});
```

## Testing Custom Hooks

Custom hooks require special consideration since they can't be tested in isolation without a component. Use renderHook from React Testing Library to test hooks independently:

```typescript
import { renderHook, act, waitFor } from "@testing-library/react";

interface UseFetchOptions<T> {
	initialData?: T;
	onSuccess?: (data: T) => void;
	onError?: (error: Error) => void;
}

interface UseFetchResult<T> {
	data: T | null;
	loading: boolean;
	error: Error | null;
	refetch: () => Promise<void>;
}

// Example custom hook
function useFetch<T>(
	url: string,
	options?: UseFetchOptions<T>,
): UseFetchResult<T> {
	// Implementation details...
}

describe("useFetch", () => {
	const mockData = { id: 1, title: "Test Item" };

	beforeEach(() => {
		global.fetch = jest.fn();
	});

	afterEach(() => {
		jest.restoreAllMocks();
	});

	it("fetches data successfully", async () => {
		(global.fetch as jest.Mock).mockResolvedValueOnce({
			ok: true,
			json: async () => mockData,
		});

		const { result } = renderHook(() =>
			useFetch<typeof mockData>("/api/items/1"),
		);

		expect(result.current.loading).toBe(true);
		expect(result.current.data).toBeNull();
		expect(result.current.error).toBeNull();

		await waitFor(() => {
			expect(result.current.loading).toBe(false);
		});

		expect(result.current.data).toEqual(mockData);
		expect(result.current.error).toBeNull();
		expect(global.fetch).toHaveBeenCalledWith(
			"/api/items/1",
			expect.any(Object),
		);
	});

	it("handles errors gracefully", async () => {
		const errorMessage = "Network error";
		(global.fetch as jest.Mock).mockRejectedValueOnce(new Error(errorMessage));

		const onError = jest.fn();
		const { result } = renderHook(() => useFetch("/api/items/1", { onError }));

		await waitFor(() => {
			expect(result.current.loading).toBe(false);
		});

		expect(result.current.data).toBeNull();
		expect(result.current.error).toEqual(new Error(errorMessage));
		expect(onError).toHaveBeenCalledWith(new Error(errorMessage));
	});

	it("supports manual refetching", async () => {
		(global.fetch as jest.Mock)
			.mockResolvedValueOnce({
				ok: true,
				json: async () => mockData,
			})
			.mockResolvedValueOnce({
				ok: true,
				json: async () => ({ ...mockData, title: "Updated Item" }),
			});

		const { result } = renderHook(() =>
			useFetch<typeof mockData>("/api/items/1"),
		);

		await waitFor(() => {
			expect(result.current.data).toEqual(mockData);
		});

		act(() => {
			result.current.refetch();
		});

		expect(result.current.loading).toBe(true);

		await waitFor(() => {
			expect(result.current.loading).toBe(false);
		});

		expect(result.current.data).toEqual({ ...mockData, title: "Updated Item" });
		expect(global.fetch).toHaveBeenCalledTimes(2);
	});
});
```

## Accessibility Testing

Accessibility should be a core concern in your tests. Beyond using semantic queries, incorporate tools like jest-axe to catch common accessibility violations:

```typescript
import { render, screen } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

interface FormFieldProps {
  label: string;
  name: string;
  type?: 'text' | 'email' | 'password' | 'number';
  required?: boolean;
  error?: string;
  helpText?: string;
}

describe('FormField Accessibility', () => {
  it('meets WCAG accessibility standards', async () => {
    const { container } = render(
      <FormField
        label="Email Address"
        name="email"
        type="email"
        required
        helpText="We'll never share your email"
      />
    );

    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it('properly associates labels with inputs', () => {
    render(
      <FormField
        label="Username"
        name="username"
        required
      />
    );

    const input = screen.getByLabelText(/username/i);
    expect(input).toHaveAttribute('id');
    expect(input).toHaveAttribute('name', 'username');
    expect(input).toHaveAttribute('aria-required', 'true');
  });

  it('announces error messages to screen readers', () => {
    const { rerender } = render(
      <FormField
        label="Password"
        name="password"
        type="password"
      />
    );

    const input = screen.getByLabelText(/password/i);
    expect(input).not.toHaveAttribute('aria-invalid');
    expect(input).not.toHaveAttribute('aria-describedby');

    rerender(
      <FormField
        label="Password"
        name="password"
        type="password"
        error="Password must be at least 8 characters"
      />
    );

    expect(input).toHaveAttribute('aria-invalid', 'true');
    expect(input).toHaveAttribute('aria-describedby');

    const errorId = input.getAttribute('aria-describedby');
    const errorMessage = document.getElementById(errorId!);
    expect(errorMessage).toHaveTextContent('Password must be at least 8 characters');
  });
});
```

## Performance Considerations in Tests

While performance testing often requires specialized tools, you can verify basic performance characteristics in your unit tests, particularly around unnecessary re-renders:

```typescript
import React, { useRef } from 'react';
import { render, screen } from '@testing-library/react';

interface ExpensiveListProps {
  items: Array<{ id: string; name: string; value: number }>;
  onItemClick: (id: string) => void;
}

const ExpensiveList = React.memo<ExpensiveListProps>(({ items, onItemClick }) => {
  const renderCount = useRef(0);
  renderCount.current += 1;

  return (
    <div data-testid="render-count" data-count={renderCount.current}>
      {items.map(item => (
        <button key={item.id} onClick={() => onItemClick(item.id)}>
          {item.name}: {item.value}
        </button>
      ))}
    </div>
  );
});

describe('ExpensiveList Performance', () => {
  it('does not re-render when props remain the same', () => {
    const items = [
      { id: '1', name: 'Item 1', value: 100 },
      { id: '2', name: 'Item 2', value: 200 }
    ];
    const handleClick = jest.fn();

    const { rerender } = render(
      <ExpensiveList items={items} onItemClick={handleClick} />
    );

    const renderCountElement = screen.getByTestId('render-count');
    expect(renderCountElement).toHaveAttribute('data-count', '1');

    // Re-render with same props
    rerender(<ExpensiveList items={items} onItemClick={handleClick} />);
    expect(renderCountElement).toHaveAttribute('data-count', '1');

    // Re-render with new items array but same content
    const newItems = [...items];
    rerender(<ExpensiveList items={newItems} onItemClick={handleClick} />);
    expect(renderCountElement).toHaveAttribute('data-count', '2');
  });

  it('re-renders when items change', () => {
    const items = [{ id: '1', name: 'Item 1', value: 100 }];
    const { rerender } = render(
      <ExpensiveList items={items} onItemClick={jest.fn()} />
    );

    const updatedItems = [...items, { id: '2', name: 'Item 2', value: 200 }];
    rerender(<ExpensiveList items={updatedItems} onItemClick={jest.fn()} />);

    expect(screen.getAllByRole('button')).toHaveLength(2);
  });
});
```

## Advanced TypeScript Patterns

TypeScript enables sophisticated type-safe testing patterns. Leverage discriminated unions, generics, and strict typing to catch errors at compile time:

```typescript
import React from 'react';
import { render, screen } from '@testing-library/react';

type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

interface AsyncDataDisplayProps<T> {
  state: AsyncState<T>;
  renderData: (data: T) => React.ReactNode;
  loadingMessage?: string;
  errorMessage?: string;
}

function AsyncDataDisplay<T>({ state, renderData, loadingMessage, errorMessage }: AsyncDataDisplayProps<T>) {
  switch (state.status) {
    case 'idle':
      return <div role="status">Ready to load data</div>;
    case 'loading':
      return <div role="status" aria-busy="true">{loadingMessage || 'Loading...'}</div>;
    case 'success':
      return <>{renderData(state.data)}</>;
    case 'error':
      return (
        <div role="alert" aria-live="assertive">
          {errorMessage || state.error.message}
        </div>
      );
  }
}

describe('AsyncDataDisplay with TypeScript', () => {
  interface UserData {
    id: string;
    name: string;
    email: string;
  }

  const renderUser = (user: UserData) => (
    <div data-testid="user-info">
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );

  it('handles all state transitions with type safety', () => {
    const { rerender } = render(
      <AsyncDataDisplay<UserData>
        state={{ status: 'idle' }}
        renderData={renderUser}
      />
    );

    expect(screen.getByRole('status')).toHaveTextContent('Ready to load data');

    rerender(
      <AsyncDataDisplay<UserData>
        state={{ status: 'loading' }}
        renderData={renderUser}
        loadingMessage="Fetching user data..."
      />
    );

    expect(screen.getByRole('status')).toHaveTextContent('Fetching user data...');
    expect(screen.getByRole('status')).toHaveAttribute('aria-busy', 'true');

    const userData: UserData = {
      id: '123',
      name: 'John Doe',
      email: 'john@example.com'
    };

    rerender(
      <AsyncDataDisplay<UserData>
        state={{ status: 'success', data: userData }}
        renderData={renderUser}
      />
    );

    expect(screen.queryByRole('status')).not.toBeInTheDocument();
    expect(screen.getByTestId('user-info')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent(userData.name);
    expect(screen.getByText(userData.email)).toBeInTheDocument();

    rerender(
      <AsyncDataDisplay<UserData>
        state={{ status: 'error', error: new Error('Failed to fetch user') }}
        renderData={renderUser}
      />
    );

    expect(screen.getByRole('alert')).toHaveTextContent('Failed to fetch user');
    expect(screen.getByRole('alert')).toHaveAttribute('aria-live', 'assertive');
  });
});
```

## Common Pitfalls and Solutions

Testing React components with TypeScript introduces unique challenges. Avoid type assertions that bypass TypeScript's safety checks. Instead of casting elements to specific types, use proper runtime checks and TypeScript's type narrowing capabilities. When mocking functions, always provide complete type information including return types and parameter types to catch mismatches during compilation.

Be cautious with async operations and ensure proper cleanup. Memory leaks in tests can cause flaky results and slow test suites. Always cancel pending requests, clear timers, and restore mocks in afterEach blocks. Use act warnings as a signal that your test might have timing issues rather than suppressing them.

Remember that TypeScript's compile-time checks don't replace runtime validation. While types ensure your test code is consistent, you still need to verify actual behavior. Test both happy paths and error scenarios, especially around type boundaries where runtime data might not match expected types.

## Conclusion

Effective React testing with TypeScript combines the best of both worlds: React Testing Library's user-centric approach and TypeScript's type safety. Focus on testing what users experience rather than implementation details, leverage TypeScript to catch errors early and document component contracts, use semantic queries to ensure accessibility, and structure tests for clarity and maintainability. Your tests should give confidence that components work correctly while serving as living documentation for how components should be used.
