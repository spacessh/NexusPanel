import React from 'react';
import { NavLink } from 'react-router-dom';
import {
    LayoutDashboard, Server, Users, HardDrive,
    Settings, Shield, Database, Activity, LogOut, Zap
} from 'lucide-react';

interface NavItem {
    to: string;
    icon: React.ReactNode;
    label: string;
    section?: string;
}

const NAV_ITEMS: NavItem[] = [
    { to: '/',          icon: <LayoutDashboard size={18} />, label: 'Dashboard',  section: 'Overview' },
    { to: '/servers',   icon: <Server size={18} />,          label: 'Servers' },
    { to: '/nodes',     icon: <Database size={18} />,        label: 'Nodes' },
    { to: '/monitoring',icon: <Activity size={18} />,        label: 'Monitoring', section: 'System' },
    { to: '/backups',   icon: <HardDrive size={18} />,       label: 'Backups' },
    { to: '/users',     icon: <Users size={18} />,           label: 'Users',      section: 'Admin' },
    { to: '/roles',     icon: <Shield size={18} />,          label: 'Roles & Perms' },
    { to: '/settings',  icon: <Settings size={18} />,        label: 'Settings' },
];

const Sidebar: React.FC = () => {
    let lastSection = '';

    return (
        <aside className="nexus-sidebar">
            <div className="nexus-sidebar-logo">
                <div className="nexus-logo-icon">⚡</div>
                <span className="nexus-logo-text">NEXUS</span>
            </div>
            <nav className="nexus-nav">
                {NAV_ITEMS.map(item => {
                    const showSection = item.section && item.section !== lastSection;
                    if (item.section) lastSection = item.section;
                    return (
                        <React.Fragment key={item.to}>
                            {showSection && (
                                <div className="nexus-nav-section">{item.section}</div>
                            )}
                            <NavLink
                                to={item.to}
                                end={item.to === '/'}
                                className={({ isActive }) => `nexus-nav-item${isActive ? ' active' : ''}`}
                            >
                                <span className="nav-icon">{item.icon}</span>
                                <span>{item.label}</span>
                            </NavLink>
                        </React.Fragment>
                    );
                })}
            </nav>
            <div style={{ padding: '16px', borderTop: '1px solid var(--nexus-border)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
                    <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'linear-gradient(135deg, var(--nexus-green3), var(--nexus-cyan))', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 700, color: '#000' }}>
                        A
                    </div>
                    <div>
                        <div style={{ fontSize: 13, fontWeight: 600 }}>Admin</div>
                        <div style={{ fontSize: 11, color: 'var(--nexus-text2)' }}>Administrator</div>
                    </div>
                </div>
                <button className="nexus-btn nexus-btn-ghost" style={{ width: '100%', justifyContent: 'center', fontSize: 12 }}>
                    <LogOut size={13} /> Sign Out
                </button>
            </div>
        </aside>
    );
};

export default Sidebar;
