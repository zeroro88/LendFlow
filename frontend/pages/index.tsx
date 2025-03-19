import React from 'react';
import Layout from '../components/Layout';

const Home = () => {
  return (
    <Layout>
      <div className="container mx-auto p-4">
        <h1 className="text-3xl font-bold mb-4">DeFi借贷平台</h1>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-2">借贷池</h2>
            <p>查看可用的借贷池和利率</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-xl font-semibold mb-2">我的借贷</h2>
            <p>管理您的借贷和质押资产</p>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Home;