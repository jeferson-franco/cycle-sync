"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Card } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/lib/supabase";
import { format } from "date-fns";
import { Calendar as CalendarIcon, Plus } from "lucide-react";
import { useRouter } from "next/navigation";

export default function DashboardPage() {
  const [date, setDate] = useState<Date>(new Date());
  const [cycles, setCycles] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const { toast } = useToast();
  const router = useRouter();

  useEffect(() => {
    checkAuth();
    fetchCycles();
  }, []);

  const checkAuth = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      router.push("/auth");
    }
  };

  const fetchCycles = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data, error } = await supabase
        .from("cycles")
        .select("*")
        .eq("user_id", user.id)
        .order("start_date", { ascending: false });

      if (error) throw error;
      setCycles(data || []);
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const startNewCycle = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { error } = await supabase
        .from("cycles")
        .insert([
          {
            user_id: user.id,
            start_date: format(date, "yyyy-MM-dd"),
          },
        ]);

      if (error) throw error;

      toast({
        title: "Success",
        description: "New cycle started!",
      });

      fetchCycles();
    } catch (error: any) {
      toast({
        title: "Error",
        description: error.message,
        variant: "destructive",
      });
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="container mx-auto px-4 py-8">
        <header className="mb-8">
          <h1 className="text-3xl font-bold text-pink-600 dark:text-pink-400">Dashboard</h1>
        </header>

        <div className="grid md:grid-cols-2 gap-8">
          <Card className="p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-semibold">Cycle Calendar</h2>
              <Button onClick={startNewCycle} size="sm">
                <Plus className="w-4 h-4 mr-2" />
                Start New Cycle
              </Button>
            </div>
            <Calendar
              mode="single"
              selected={date}
              onSelect={(date) => date && setDate(date)}
              className="rounded-md border"
            />
          </Card>

          <Card className="p-6">
            <h2 className="text-xl font-semibold mb-6">Cycle History</h2>
            {loading ? (
              <p>Loading...</p>
            ) : cycles.length > 0 ? (
              <div className="space-y-4">
                {cycles.map((cycle) => (
                  <div
                    key={cycle.id}
                    className="flex items-center justify-between p-4 rounded-lg bg-secondary"
                  >
                    <div className="flex items-center">
                      <CalendarIcon className="w-5 h-5 mr-3 text-pink-500" />
                      <span>{format(new Date(cycle.start_date), "PPP")}</span>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-muted-foreground">No cycles recorded yet.</p>
            )}
          </Card>
        </div>
      </div>
    </div>
  );
}