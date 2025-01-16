import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Heart, Calendar, Utensils, Users } from "lucide-react";
import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-pink-50 to-white dark:from-pink-950 dark:to-background">
      <div className="container mx-auto px-4 py-16">
        <header className="text-center mb-16">
          <h1 className="text-4xl md:text-6xl font-bold text-pink-600 dark:text-pink-400 mb-4">
            CycleSync
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            Your personalized menstrual health companion for better nutrition and partner support
          </p>
        </header>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mb-16">
          <Card className="p-6 hover:shadow-lg transition-shadow">
            <Heart className="w-12 h-12 text-pink-500 mb-4" />
            <h2 className="text-xl font-semibold mb-2">Cycle Tracking</h2>
            <p className="text-gray-600 dark:text-gray-300">
              Smart menstrual cycle tracking with personalized insights
            </p>
          </Card>

          <Card className="p-6 hover:shadow-lg transition-shadow">
            <Calendar className="w-12 h-12 text-pink-500 mb-4" />
            <h2 className="text-xl font-semibold mb-2">Symptom Logging</h2>
            <p className="text-gray-600 dark:text-gray-300">
              Track symptoms and get phase-specific recommendations
            </p>
          </Card>

          <Card className="p-6 hover:shadow-lg transition-shadow">
            <Utensils className="w-12 h-12 text-pink-500 mb-4" />
            <h2 className="text-xl font-semibold mb-2">Nutrition Guide</h2>
            <p className="text-gray-600 dark:text-gray-300">
              Personalized nutrition advice for each cycle phase
            </p>
          </Card>

          <Card className="p-6 hover:shadow-lg transition-shadow">
            <Users className="w-12 h-12 text-pink-500 mb-4" />
            <h2 className="text-xl font-semibold mb-2">Partner Support</h2>
            <p className="text-gray-600 dark:text-gray-300">
              Connect with partners for better understanding and support
            </p>
          </Card>
        </div>

        <div className="text-center">
          <Button asChild size="lg" className="bg-pink-600 hover:bg-pink-700">
            <Link href="/auth">Get Started</Link>
          </Button>
        </div>
      </div>
    </div>
  );
}