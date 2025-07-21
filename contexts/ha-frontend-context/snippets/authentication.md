# Authentication Patterns

## SSO Integration with HA Authentication

```typescript
// auth/sso.ts
import { NextAuthOptions } from 'next-auth';
import { Provider } from 'next-auth/providers';

export const authOptions: NextAuthOptions = {
  providers: [
    {
      id: 'ha-sso',
      name: 'Hospital Authority SSO',
      type: 'oauth',
      authorization: {
        url: process.env.HA_SSO_AUTH_URL,
        params: {
          scope: 'openid profile email',
          response_type: 'code',
        },
      },
      token: process.env.HA_SSO_TOKEN_URL,
      userinfo: process.env.HA_SSO_USERINFO_URL,
      client: {
        id: process.env.HA_SSO_CLIENT_ID,
        secret: process.env.HA_SSO_CLIENT_SECRET,
      },
      profile(profile) {
        return {
          id: profile.sub,
          name: profile.name,
          email: profile.email,
          role: profile.role,
          department: profile.department,
        };
      },
    },
  ],
  callbacks: {
    async jwt({ token, account, profile }) {
      if (account && profile) {
        token.role = profile.role;
        token.department = profile.department;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.role = token.role;
        session.user.department = token.department;
      }
      return session;
    },
  },
};
```

## Protected Route Component

```typescript
// components/auth/ProtectedRoute.tsx
import { useSession } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { ReactNode, useEffect } from 'react';

interface ProtectedRouteProps {
  children: ReactNode;
  requiredRole?: string;
  requiredPermission?: string;
}

export function ProtectedRoute({ 
  children, 
  requiredRole,
  requiredPermission 
}: ProtectedRouteProps) {
  const { data: session, status } = useSession();
  const router = useRouter();

  useEffect(() => {
    if (status === 'loading') return;
    
    if (!session) {
      router.push('/auth/signin');
      return;
    }

    if (requiredRole && session.user.role !== requiredRole) {
      router.push('/unauthorized');
      return;
    }

    if (requiredPermission && !hasPermission(session.user, requiredPermission)) {
      router.push('/unauthorized');
      return;
    }
  }, [session, status, requiredRole, requiredPermission, router]);

  if (status === 'loading') {
    return <div>Loading...</div>;
  }

  if (!session) {
    return null;
  }

  return <>{children}</>;
}
```

## Session Management Hook

```typescript
// hooks/useAuth.ts
import { useSession, signIn, signOut } from 'next-auth/react';
import { useCallback } from 'react';

export function useAuth() {
  const { data: session, status } = useSession();

  const login = useCallback(async () => {
    await signIn('ha-sso');
  }, []);

  const logout = useCallback(async () => {
    await signOut({ callbackUrl: '/' });
  }, []);

  const hasRole = useCallback((role: string) => {
    return session?.user?.role === role;
  }, [session]);

  const hasPermission = useCallback((permission: string) => {
    return session?.user?.permissions?.includes(permission) || false;
  }, [session]);

  return {
    user: session?.user,
    isAuthenticated: !!session,
    isLoading: status === 'loading',
    login,
    logout,
    hasRole,
    hasPermission,
  };
}
``` 