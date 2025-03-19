import React from 'react';
import Head from 'next/head';

interface LayoutProps {
  children: React.ReactNode;
}

const Layout = ({ children }: LayoutProps) => {
  return (
    <>
      <Head>
        <title>LendFlow - DeFi借贷平台</title>
        <meta name="description" content="去中心化金融借贷平台" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main>
        <nav className="bg-blue-600 text-white p-4">
          <h1 className="text-xl font-bold">LendFlow</h1>
        </nav>
        {children}
      </main>
    </>
  );
};

export default Layout;