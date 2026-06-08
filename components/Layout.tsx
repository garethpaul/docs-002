import React, { ReactNode } from "react";
import Head from "next/head";
import Navigation from "./Navigation";
import styles from "./Layout.module.css";

type Props = {
  children?: ReactNode;
  title?: string;
};

// rewrite as a function to set states
const Layout: React.FC<Props> = ({
  children,
  title = "Home | Next.js + TypeScript Example",
}) => {
  return (
    <div className={styles.layout}>
      <Head>
        <title>{title}</title>
        <meta charSet="utf-8" />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <Navigation />
      <div style={{ padding: "10px" }}>{children}</div>
    </div>
  );
};

export default Layout;
