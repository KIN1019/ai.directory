"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { useState, useEffect } from "react";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { ChevronDown, ChevronRight, X } from "lucide-react";

export type FilterCategory = {
  slug: string;
  name: string;
}

export type FilterGroup = {
  name: string;
  key: string;
  items: FilterCategory[];
}

interface ContextsMultiSelectSidebarProps {
  filterGroups: FilterGroup[];
  error?: string;
}

export function ContextsMultiSelectSidebar({ filterGroups, error }: ContextsMultiSelectSidebarProps) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [selectedFilters, setSelectedFilters] = useState<Record<string, string[]>>({});
  const [expandedGroups, setExpandedGroups] = useState<string[]>([]);
  const [isInitialized, setIsInitialized] = useState(false);

  // Initialize selected filters from URL params
  useEffect(() => {
    const filters: Record<string, string[]> = {};
    filterGroups.forEach(group => {
      const param = searchParams.get(group.key);
      if (param) {
        filters[group.key] = param.split(',').filter(Boolean);
      }
    });
    setSelectedFilters(filters);
    
    // Only initialize expanded groups once, not on every filter change
    if (!isInitialized) {
      // Expand groups that have selected filters on initial load
      setExpandedGroups(Object.keys(filters));
      setIsInitialized(true);
    }
  }, [searchParams, filterGroups, isInitialized]);

  const handleFilterClick = (groupKey: string, itemSlug: string) => {
    const currentFilters = selectedFilters[groupKey] || [];
    const isSelected = currentFilters.includes(itemSlug);
    
    const newFilters = isSelected
      ? currentFilters.filter(f => f !== itemSlug)
      : [...currentFilters, itemSlug];
    
    const updatedFilters = {
      ...selectedFilters,
      [groupKey]: newFilters
    };
    
    if (newFilters.length === 0) {
      delete updatedFilters[groupKey];
    }
    
    setSelectedFilters(updatedFilters);
    
    // Update URL
    const params = new URLSearchParams(searchParams);
    
    // Update each filter group in the URL
    Object.entries(updatedFilters).forEach(([key, values]) => {
      if (values.length > 0) {
        params.set(key, values.join(','));
      } else {
        params.delete(key);
      }
    });
    
    // Remove filters that are not in updatedFilters
    filterGroups.forEach(group => {
      if (!updatedFilters[group.key]) {
        params.delete(group.key);
      }
    });
    
    router.push(`/contexts?${params.toString()}`);
  };

  const clearAllFilters = () => {
    setSelectedFilters({});
    router.push('/contexts');
  };

  const toggleGroup = (groupKey: string) => {
    setExpandedGroups(prev => 
      prev.includes(groupKey) 
        ? prev.filter(g => g !== groupKey)
        : [...prev, groupKey]
    );
  };

  const totalSelectedFilters = Object.values(selectedFilters).flat().length;

  if (error) {
    return (
      <div className="w-[280px] border-r h-screen overflow-y-auto">
        <div className="p-4">
          <h2 className="text-lg font-semibold mb-4">Filters</h2>
          <p className="text-red-500 text-sm">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="w-[280px] border-r h-screen overflow-y-auto">
      <div className="p-4">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-sm font-semibold">Filters</h2>
          {totalSelectedFilters > 0 && (
            <button
              onClick={clearAllFilters}
              className="text-sm text-muted-foreground hover:text-foreground flex items-center gap-1"
            >
              Clear all
              <X className="w-3 h-3" />
            </button>
          )}
        </div>
        
        <div className="space-y-4">
          {filterGroups.map((group) => {
            const isExpanded = expandedGroups.includes(group.key);
            const selectedCount = (selectedFilters[group.key] || []).length;
            
            return (
              <div key={group.key}>
                <button
                  onClick={() => toggleGroup(group.key)}
                  className="flex items-center justify-between w-full text-left mb-2 hover:text-foreground transition-colors"
                >
                  <span className="text-sm font-medium flex items-center gap-1">
                    {isExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                    {group.name}
                  </span>
                  <div className="min-w-[24px] flex justify-end items-center">
                    {selectedCount > 0 && (
                      <Badge variant="secondary" className="text-xs h-5 min-w-[20px] flex items-center justify-center">
                        {selectedCount}
                      </Badge>
                    )}
                  </div>
                </button>
                
                {isExpanded && (
                  <div className="space-y-1 ml-4">
                    {group.items.map((item) => {
                      const isSelected = (selectedFilters[group.key] || []).includes(item.slug);
                      return (
                        <div
                          key={item.slug}
                          onClick={() => handleFilterClick(group.key, item.slug)}
                          className={`flex items-center justify-between p-2 rounded-md cursor-pointer transition-colors text-sm ${
                            isSelected
                              ? 'bg-primary text-primary-foreground'
                              : 'hover:bg-muted'
                          }`}
                        >
                          <span>{item.name}</span>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {totalSelectedFilters > 0 && (
          <>
            <Separator className="my-4" />
            <div>
              <h3 className="text-sm font-medium mb-2">Active Filters ({totalSelectedFilters})</h3>
              <div className="flex flex-wrap gap-1">
                {Object.entries(selectedFilters).map(([groupKey, filters]) => {
                  const group = filterGroups.find(g => g.key === groupKey);
                  return filters.map((filterSlug) => {
                    const filter = group?.items.find(i => i.slug === filterSlug);
                    return filter ? (
                      <Badge 
                        key={`${groupKey}-${filterSlug}`} 
                        variant="default" 
                        className="text-xs cursor-pointer"
                        onClick={() => handleFilterClick(groupKey, filterSlug)}
                      >
                        {filter.name}
                        <X className="w-3 h-3 ml-1" />
                      </Badge>
                    ) : null;
                  });
                })}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
