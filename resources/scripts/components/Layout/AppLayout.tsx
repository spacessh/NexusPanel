import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import AnimatedBackground from '@/components/Dashboard/AnimatedBackground';
import { Bell, Search } from 'lucide-react';

const AppLayout: React.FC = () => (
    <div className="nexus-app">
        <AnimatedBackground />
        <Sidebar />
        <div className="nexus-content">
            {/* Topbar */}
            <header className="nexus-topbar">
                <div style={{ flex: 1, position: 'relative' }}>
                    <Search size={14} style={{ position: 'absolute', left: 10, top: '50%', transform: 'translateY(-50%)', color: 'var(--nexus-text2)' }} />
                    <input
                        className="nexus-input"
                        style={{ paddingLeft: 32, height: 36, fontSize: 13 }}
                        placeholder="Search servers, users..."
                    />
                </div>
                <button className="nexus-btn nexus-btn-ghost" style={{ padding: '6px 10px', position: 'relative' }}>
                    <Bell size={16} />
                    <span style={{
                        position: 'absolute', top: 4, right: 4,
                        width: 8, height: 8, borderRadius: '50%',
                        background: 'var(--nexus-red)',
                        border: '2px solid var(--nexus-bg)',
                    }} />
                </button>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 13 }}>
                    <div style={{ width: 28, height: 28, borderRadius: '50%', background: 'linear-gradient(135deg, var(--nexus-green3), var(--nexus-cyan))', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 700, color: '#000' }}>
                        A
                    </div>
                    <span style={{ color: 'var(--nexus-text2)' }}>Admin</span>
                </div>
            </header>
            <main className="nexus-main">
                <Outlet />
            </main>
        </div>
    </div>
);

export default AppLayout;
