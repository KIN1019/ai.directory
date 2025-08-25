# Component Examples

## CMS Design System Components

### Patient Information Card

```typescript
// components/PatientCard.tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { CalendarDays, Phone, Mail, MapPin } from 'lucide-react';

interface Patient {
  id: string;
  name: string;
  hkid: string;
  dateOfBirth: string;
  gender: 'M' | 'F';
  phoneNumber?: string;
  email?: string;
  address?: string;
  avatar?: string;
}

interface PatientCardProps {
  patient: Patient;
  onClick?: () => void;
}

export function PatientCard({ patient, onClick }: PatientCardProps) {
  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const getAge = (dateOfBirth: string) => {
    const today = new Date();
    const birth = new Date(dateOfBirth);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
      age--;
    }
    
    return age;
  };

  return (
    <Card 
      className="hover:shadow-md transition-shadow cursor-pointer"
      onClick={onClick}
    >
      <CardHeader className="pb-3">
        <div className="flex items-center space-x-3">
          <Avatar className="h-12 w-12">
            <AvatarImage src={patient.avatar} alt={patient.name} />
            <AvatarFallback>{getInitials(patient.name)}</AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <CardTitle className="text-lg truncate">{patient.name}</CardTitle>
            <div className="flex items-center gap-2 mt-1">
              <Badge variant="outline" className="text-xs">
                {patient.hkid}
              </Badge>
              <Badge variant="secondary" className="text-xs">
                {patient.gender === 'M' ? 'Male' : 'Female'}, {getAge(patient.dateOfBirth)}
              </Badge>
            </div>
          </div>
        </div>
      </CardHeader>
      <CardContent className="pt-0">
        <div className="space-y-2 text-sm text-muted-foreground">
          <div className="flex items-center gap-2">
            <CalendarDays className="h-4 w-4" />
            <span>Born: {new Date(patient.dateOfBirth).toLocaleDateString()}</span>
          </div>
          
          {patient.phoneNumber && (
            <div className="flex items-center gap-2">
              <Phone className="h-4 w-4" />
              <span>{patient.phoneNumber}</span>
            </div>
          )}
          
          {patient.email && (
            <div className="flex items-center gap-2">
              <Mail className="h-4 w-4" />
              <span className="truncate">{patient.email}</span>
            </div>
          )}
          
          {patient.address && (
            <div className="flex items-start gap-2">
              <MapPin className="h-4 w-4 mt-0.5" />
              <span className="line-clamp-2">{patient.address}</span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
```

### Data Table with Pagination

```typescript
// components/PatientTable.tsx
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { ChevronLeft, ChevronRight, Search } from 'lucide-react';
import { useState } from 'react';

interface PatientTableProps {
  patients: Patient[];
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  onSearch: (query: string) => void;
  onPatientClick: (patient: Patient) => void;
}

export function PatientTable({
  patients,
  currentPage,
  totalPages,
  onPageChange,
  onSearch,
  onPatientClick
}: PatientTableProps) {
  const [searchQuery, setSearchQuery] = useState('');

  const handleSearch = (value: string) => {
    setSearchQuery(value);
    onSearch(value);
  };

  return (
    <div className="space-y-4">
      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
        <Input
          placeholder="Search patients..."
          value={searchQuery}
          onChange={(e) => handleSearch(e.target.value)}
          className="pl-10"
        />
      </div>

      {/* Table */}
      <div className="rounded-md border">
        <Table>
          <TableCaption>A list of registered patients.</TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>HKID</TableHead>
              <TableHead>Gender</TableHead>
              <TableHead>Age</TableHead>
              <TableHead>Contact</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {patients.map((patient) => (
              <TableRow 
                key={patient.id}
                className="cursor-pointer hover:bg-muted/50"
                onClick={() => onPatientClick(patient)}
              >
                <TableCell className="font-medium">{patient.name}</TableCell>
                <TableCell>
                  <Badge variant="outline">{patient.hkid}</Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={patient.gender === 'M' ? 'default' : 'secondary'}>
                    {patient.gender === 'M' ? 'Male' : 'Female'}
                  </Badge>
                </TableCell>
                <TableCell>{getAge(patient.dateOfBirth)}</TableCell>
                <TableCell>
                  <div className="text-sm">
                    {patient.phoneNumber && <div>{patient.phoneNumber}</div>}
                    {patient.email && <div className="text-muted-foreground">{patient.email}</div>}
                  </div>
                </TableCell>
                <TableCell>
                  <Button variant="outline" size="sm">
                    View Details
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-between">
        <div className="text-sm text-muted-foreground">
          Page {currentPage} of {totalPages}
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => onPageChange(currentPage - 1)}
            disabled={currentPage <= 1}
          >
            <ChevronLeft className="h-4 w-4" />
            Previous
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => onPageChange(currentPage + 1)}
            disabled={currentPage >= totalPages}
          >
            Next
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
``` 