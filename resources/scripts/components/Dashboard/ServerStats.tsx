import React from 'react';
import { Server, Cpu, HardDrive, Wifi, Users } from 'lucide-react';

interface StatCardProps {
    label: string;
    value: string | number;
    icon: React.ReactNode;
    color?: string;
    sub?: string;
}

const StatCard: React.FC<StatCardProps> = ({ label, value, icon, sub }) => (
    <div className="nexus-stat-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
                <div className="nexus-stat-value">{value}</div>
                <div className="nexus-stat-label">{label}</div>
                {sub && <div style={{ fontSize: 11, color: 'var(--nexus-text2)', marginTop: 4 }}>{sub}</div>}
            </div>
            <div style={{ color: 'var(--nexus-green)', opacity: 0.7 }}>{icon}</div>
        </div>
    </div>
);

interface ServerStatsProps {
    stats: {
        totalServers: number;
        onlineServers: number;
        totalUsers: number;
        cpuUsage: number;
        ramUsage: number;
        diskUsage: number;
    };
}

const ServerStats: React.FC<ServerStatsProps> = ({ stats }) => (
    <div className="nexus-stat-grid">
        <StatCard label="Total Servers"  value={stats.totalServers}  icon={<Server size={24} />} sub={`${stats.onlineServers} online`} />
        <StatCard label="Active Users"   value={stats.totalUsers}    icon={<Users size={24} />} />
        <StatCard label="CPU Usage"      value={`${stats.cpuUsage}%`}  icon={<Cpu size={24} />} />
        <StatCard label="RAM Usage"      value={`${stats.ramUsage}%`}  icon={<HardDrive size={24} />} />
        <StatCard label="Disk Usage"     value={`${stats.diskUsage}%`} icon={<HardDrive size={24} />} />
        <StatCard label="Network"        value="Active"              icon={<Wifi size={24} />} />
    </div>
);

export default ServerStats;
