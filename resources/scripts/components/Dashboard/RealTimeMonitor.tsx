import React, { useEffect, useState } from 'react';
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

interface DataPoint { time: string; cpu: number; ram: number; net: number; }

const generatePoint = (): DataPoint => ({
    time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
    cpu: Math.floor(Math.random() * 40 + 20),
    ram: Math.floor(Math.random() * 30 + 40),
    net: Math.floor(Math.random() * 50 + 10),
});

const CustomTooltip = ({ active, payload, label }: any) => {
    if (!active || !payload?.length) return null;
    return (
        <div style={{ background: 'rgba(8,15,20,0.95)', border: '1px solid var(--nexus-border)', borderRadius: 8, padding: '10px 14px', fontSize: 12 }}>
            <div style={{ color: 'var(--nexus-text2)', marginBottom: 6 }}>{label}</div>
            {payload.map((p: any) => (
                <div key={p.name} style={{ color: p.color, marginBottom: 2 }}>
                    {p.name.toUpperCase()}: {p.value}%
                </div>
            ))}
        </div>
    );
};

const RealTimeMonitor: React.FC = () => {
    const [data, setData] = useState<DataPoint[]>(() => Array.from({ length: 20 }, generatePoint));

    useEffect(() => {
        const interval = setInterval(() => {
            setData(prev => [...prev.slice(-19), generatePoint()]);
        }, 2000);
        return () => clearInterval(interval);
    }, []);

    return (
        <div className="nexus-card">
            <div className="nexus-card-header">
                <span className="nexus-card-title">⚡ Real-Time Monitor</span>
                <span style={{ fontSize: 11, color: 'var(--nexus-green)', display: 'flex', alignItems: 'center', gap: 4 }}>
                    <span className="nexus-badge-dot" style={{ background: 'var(--nexus-green)' }} />
                    LIVE
                </span>
            </div>
            <ResponsiveContainer width="100%" height={200}>
                <AreaChart data={data} margin={{ top: 5, right: 5, bottom: 5, left: -20 }}>
                    <defs>
                        <linearGradient id="cpuGrad" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%"  stopColor="#00ff88" stopOpacity={0.3} />
                            <stop offset="95%" stopColor="#00ff88" stopOpacity={0} />
                        </linearGradient>
                        <linearGradient id="ramGrad" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%"  stopColor="#00e5ff" stopOpacity={0.3} />
                            <stop offset="95%" stopColor="#00e5ff" stopOpacity={0} />
                        </linearGradient>
                        <linearGradient id="netGrad" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%"  stopColor="#9966ff" stopOpacity={0.3} />
                            <stop offset="95%" stopColor="#9966ff" stopOpacity={0} />
                        </linearGradient>
                    </defs>
                    <XAxis dataKey="time" tick={{ fill: '#7ab0c8', fontSize: 10 }} tickLine={false} axisLine={false} interval="preserveStartEnd" />
                    <YAxis tick={{ fill: '#7ab0c8', fontSize: 10 }} tickLine={false} axisLine={false} domain={[0, 100]} />
                    <Tooltip content={<CustomTooltip />} />
                    <Area type="monotone" dataKey="cpu" stroke="#00ff88" strokeWidth={2} fill="url(#cpuGrad)" name="cpu" dot={false} />
                    <Area type="monotone" dataKey="ram" stroke="#00e5ff" strokeWidth={2} fill="url(#ramGrad)" name="ram" dot={false} />
                    <Area type="monotone" dataKey="net" stroke="#9966ff" strokeWidth={2} fill="url(#netGrad)" name="net" dot={false} />
                </AreaChart>
            </ResponsiveContainer>
            <div style={{ display: 'flex', gap: 20, marginTop: 8, fontSize: 11 }}>
                {[['CPU', '#00ff88'], ['RAM', '#00e5ff'], ['NET', '#9966ff']].map(([label, color]) => (
                    <span key={label} style={{ display: 'flex', alignItems: 'center', gap: 5, color: 'var(--nexus-text2)' }}>
                        <span style={{ width: 20, height: 2, background: color, display: 'inline-block', borderRadius: 1 }} />
                        {label}
                    </span>
                ))}
            </div>
        </div>
    );
};

export default RealTimeMonitor;
