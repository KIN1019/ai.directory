# API Integration Patterns

## Base API Client with Authentication

```typescript
// lib/api/client.ts
import { getSession } from 'next-auth/react';

class ApiClient {
  private baseURL: string;

  constructor(baseURL: string) {
    this.baseURL = baseURL;
  }

  private async getHeaders(): Promise<HeadersInit> {
    const session = await getSession();
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    };

    if (session?.accessToken) {
      headers['Authorization'] = `Bearer ${session.accessToken}`;
    }

    return headers;
  }

  async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    const headers = await this.getHeaders();

    const response = await fetch(url, {
      ...options,
      headers: {
        ...headers,
        ...options.headers,
      },
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      throw new ApiError(response.status, error.message || response.statusText);
    }

    return response.json();
  }

  get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  post<T>(endpoint: string, data?: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  put<T>(endpoint: string, data?: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }
}

export const apiClient = new ApiClient(process.env.NEXT_PUBLIC_API_URL || '');
```

## Type-Safe API Hooks with React Query

```typescript
// hooks/api/usePatients.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';

interface Patient {
  id: string;
  name: string;
  hkid: string;
  dateOfBirth: string;
  gender: 'M' | 'F';
  phoneNumber?: string;
  address?: string;
}

interface PatientsResponse {
  data: Patient[];
  total: number;
  page: number;
  pageSize: number;
}

export function usePatients(page = 1, pageSize = 20) {
  return useQuery({
    queryKey: ['patients', page, pageSize],
    queryFn: () => apiClient.get<PatientsResponse>(`/patients?page=${page}&pageSize=${pageSize}`),
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
}

export function usePatient(id: string) {
  return useQuery({
    queryKey: ['patient', id],
    queryFn: () => apiClient.get<Patient>(`/patients/${id}`),
    enabled: !!id,
  });
}

export function useCreatePatient() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Omit<Patient, 'id'>) => 
      apiClient.post<Patient>('/patients', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['patients'] });
    },
  });
}

export function useUpdatePatient() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, ...data }: Patient) => 
      apiClient.put<Patient>(`/patients/${id}`, data),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['patients'] });
      queryClient.setQueryData(['patient', data.id], data);
    },
  });
}
```

## Error Handling and Retry Logic

```typescript
// lib/api/error-handler.ts
export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }

  get isUnauthorized() {
    return this.status === 401;
  }

  get isForbidden() {
    return this.status === 403;
  }

  get isNotFound() {
    return this.status === 404;
  }

  get isServerError() {
    return this.status >= 500;
  }
}

// hooks/api/useApiErrorHandler.ts
import { useRouter } from 'next/navigation';
import { useCallback } from 'react';
import { toast } from 'sonner';

export function useApiErrorHandler() {
  const router = useRouter();

  const handleError = useCallback((error: unknown) => {
    if (error instanceof ApiError) {
      if (error.isUnauthorized) {
        toast.error('Session expired. Please login again.');
        router.push('/auth/signin');
        return;
      }

      if (error.isForbidden) {
        toast.error('You do not have permission to perform this action.');
        return;
      }

      if (error.isNotFound) {
        toast.error('The requested resource was not found.');
        return;
      }

      if (error.isServerError) {
        toast.error('Server error. Please try again later.');
        return;
      }
    }

    toast.error('An unexpected error occurred.');
    console.error(error);
  }, [router]);

  return { handleError };
}
``` 