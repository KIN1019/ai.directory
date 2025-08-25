"use client";

import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";
import { useRouter } from "next/navigation";

export function BackButton() {
  const router = useRouter();

  const handleBack = () => {
    router.push('/contexts');
  };

  return (
    <Button 
      variant="outline" 
      size="sm" 
      onClick={handleBack}
      className="mb-6"
    >
      <ArrowLeft className="w-4 h-4 mr-2" />
      Back to Contexts
    </Button>
  );
} 