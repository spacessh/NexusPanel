import React from 'react';
import ServerStats from '@/components/Dashboard/ServerStats';
import RealTimeMonitor from '@/components/Dashboard/RealTimeMonitor';
import ServerList from '@/components/Servers/ServerList';

const MOCK_STATS = {
    totalServers: 12,
    onlineServers: 8,
    totalUsers: 47,
    cpuUsage: 34,
    ramUsage: 62,
    diskUsage: 41,
};

const Dashboard: React.FC = () => (
    <div>
        <div style={{ marginBottom: 24 }}>
            <h1 style={{ fontSize: 24, fontWeight: 700, marginBottom: 4 }}>
                Dashboard
            </h1>
            <p style={{ color: 'var(--nexus-text2)', fontSize: 14 }}>
                Welcome back — here's your infrastructure overview.
            </p>
        </div>
        <ServerStats stats={MOCK_STATS} />
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 24 }}>
            <RealTimeMonitor />
            <div className="nexus-card">
                <div className="nexus-card-header">
                    <span className="nexus-card-title">🔔 Recent Events</span>
                </div>
                {[
                    { time: '10:05', msg: 'Server "Minecraft SMP" restarted', color: 'var(--nexus-yellow)' },
                    { time: '09:52', msg: 'User alex joined server CS2',       color: 'var(--nexus-green)' },
                    { time: '09:41', msg: 'Backup completed for Rust Survival', color: 'var(--nexus-cyan)' },
                    { time: '09:30', msg: 'ARK Cluster CPU alert: 89%',         color: 'var(--nexus-red)' },
                    { time: '09:15', msg: 'New server "Valheim World" created',  color: 'var(--nexus-green)' },
                ].map((e, i) => (
                    <div key={i} style={{ display: 'flex', gap: 12, padding: '8px 0', borderBottom: '1px solid rgba(26,58,74,0.4)', fontSize: 13 }}>
                        <span style={{ color: 'var(--nexus-text2)', fontSize: 11, minWidth: 40 }}>{e.time}</span>
                        <span style={{ color: e.color }}>{e.msg}</span>
                    </div>
                ))}
            </div>
        </div>
        <ServerList />
    </div>
);

export default Dashboard;
