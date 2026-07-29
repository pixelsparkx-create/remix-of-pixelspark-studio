import { useRouterState } from "@tanstack/react-router";
import { ReactNode, useEffect } from "react";

export function PageTransition({ children }: { children: ReactNode }) {
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: "auto" });
  }, [pathname]);

  return (
    <div key={pathname} className="animate-fade-in">
      {children}
    </div>
  );
}
