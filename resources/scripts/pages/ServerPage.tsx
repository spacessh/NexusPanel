import React, { useState } from 'react';
import { useParams } from 'react-router-dom';
import { Terminal, Folder, BarChart2, Settings, Play, Square, RotateCcw } from 'lucide-react';
import ServerConsole from '@/components/Console/ServerConsole';
import FileExplorer from '@/components/FileManager/FileExplorer';
import CPUChart from '@/components/Monitoring/CPUChart';
import MemoryChart from '@/components/Monitoring/MemoryChart';
import NetworkChart from '@/components/Monitoring/NetworkChart';

type Tab = 'console' | 'files' | 'monitoring' | 'settings';

const ServerPage: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const [tab, setTab] = useState<Tab>('console');
    const [status, setStatus] = useState<'online' | 'offline' | 'starting' | 'stopping'>('online');

    const tabs: { key: Tab; label: string; icon: React.ReactNode }[] = [
        { key: 'console',    label: 'Console',    icon: <Terminal size={14} /> },
        { key: 'files',      label: 'Files',      icon: <Folder size={14} /> },
        { key: 'monitoring', label: 'Monitoring', icon: <BarChart2 size={14} /> },
        { key: 'settings',   label: 'Settings',   icon: <Settings size={14} /> },
    ];

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
                <div>
                    <h1 style={{ fontSize: 22, fontWeight: 700 }}>Server #{id}</h1>
                    <span className={`nexus-badge nexus-badge-${status}`} style={{ marginTop: 6, display: 'inline-flex' }}>
                        <span className="nexus-badge-dot" />{status}
                    </span>
                </div>
                <div style={{ display: 'flex', gap: 8 }}>
                    <button className="nexus-btn nexus-btn-primary" onClick={() => setStatus('starting')}>
                        <Play size={13} /> Start
                    </button>
                    <button className="nexus-btn nexus-btn-danger" onClick={() => setStatus('stopping')}>
                        <Square size={13} /> Stop
                    </button>
                    <button className="nexus-btn nexus-btn-ghost" onClick={() => setStatus('starting')}>
                        <RotateCcw size={13} /> Restart
                    </button>
                </div>
            </div>

            {/* Tabs */}
            <div style={{ display: 'flex', gap: 2, marginBottom: 20, borderBottom: '1px solid var(--nexus-border)', paddingBottom: 0 }}>
                {tabs.map(t => (
                    <button
                        key={t.key}
                        onClick={() => setTab(t.key)}
                        style={{
                            display: 'flex', alignItems: 'center', gap: 6,
                            padding: '10px 16px', fontSize: 13, cursor: 'pointer',
                            background: 'transparent', border: 'none',
                            color: tab === t.key ? 'var(--nexus-green)' : 'var(--nexus-text2)',
                            borderBottom: tab === t.key ? '2px solid var(--nexus-green)' : '2px solid transparent',
                            marginBottom: -1, transition: 'all 0.2s',
                        }}
                    >
                        {t.icon} {t.label}
                    </button>
                ))}
            </div>

            {tab === 'console'    && <ServerConsole serverId={id} />}
            {tab === 'files'      && <FileExplorer serverId={id} />}
            {tab === 'monitoring' && (
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
                    <CPUChart serverId={id} />
                    <MemoryChart maxMb={4096} />
                    <NetworkChart />
                    <div className="nexus-card">
                        <div className="nexus-card-header">
                            <span className="nexus-card-title">📊 Disk Usage</span>
                        </div>
                        <div style={{ textAlign: 'center', padding: '20px 0' }}>
                            <div style={{ fontSize: 36, fontWeight: 700, color: 'var(--nexus-green)', fontFamily: 'monospace' }}>12.4 GB</div>
                            <div style={{ color: 'var(--nexus-text2)', fontSize: 13, marginTop: 4 }}>of 50 GB allocated</div>
                            <div className="nexus-progress" style={{ marginTop: 16 }}>
                                <div className="nexus-progress-bar" style={{ width: '24.8%' }} />
                            </div>
                        </div>
                    </div>
                </div>
            )}
            {tab === 'settings' && (
                <div className="nexus-card">
                    <div className="nexus-card-header">
                        <span className="nexus-card-title">⚙️ Server Settings</span>
                    </div>
                    <div style={{ display: 'grid', gap: 16, maxWidth: 500 }}>
                        {[
                            { label: 'Server Name', value: `Server #${id}` },
                            { label: 'Memory Limit (MB)', value: '4096' },
                            { label: 'CPU Limit (%)', value: '200' },
                            { label: 'Disk Limit (MB)', value: '51200' },
                        ].map(field => (
                            <div key={field.label}>
                                <label style={{ display: 'block', fontSize: 12, color: 'var(--nexus-text2)', marginBottom: 6, textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                                    {field.label}
                                </label>
                                <input className="nexus-input" defaultValue={field.value} />
                            </div>
                        ))}
                        <button className="nexus-btn nexus-btn-primary" style={{ width: 'fit-content' }}>
                            Save Changes
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ServerPage;
