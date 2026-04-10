import React, { useEffect, useState } from 'react';
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { HardDrive } from 'lucide-react';

interface DataPoint { time: string; used: number; total: number; }

const MemoryChart: React.FC<{ maxMb?: number }> = ({ maxMb = 4096 }) => {
    const [data, setData] = useState<DataPoint[]>(() =>
        Array.from({ length: 30 }, (_, i) => ({
            time: `${i}s`,
            used: Math.floor(Math.random() * 1500 + 1000),
            total: maxMb,
        }))
    );
    const current = data[data.length - 1]?.used ?? 0;
    const pct = Math.round((current / maxMb) * 100);

    useEffect(() => {
        let tick = 30;
        const interval = setInterval(() => {
            setData(prev => [...prev.slice(-29), {
                time: `${tick++}s`,
                used: Math.floor(Math.random() * 1500 + 1000),
                total: maxMb,
            }]);
        }, 2000);
        return () => clearInterval(interval);
    }, [maxMb]);

    return (
        <div className="nexus-card">
            <div className="nexus-card-header">
                <span className="nexus-card-title"><HardDrive size={14} /> Memory</span>
                <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: 18, fontWeight: 700, color: 'var(--nexus-cyan)', fontFamily: 'monospace' }}>{pct}%</div>
                    <div style={{ fontSize: 11, color: 'var(--nexus-text2)' }}>{(current / 1024).toFixed(1)} / {(maxMb / 1024).toFixed(1)} GB</div>
                </div>
            </div>
            <ResponsiveContainer width="100%" height={120}>
                <AreaChart data={data} margin={{ top: 5, right: 5, bottom: 0, left: -30 }}>
                    <defs>
                        <linearGradient id="memGrad" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%"  stopColor="#00e5ff" stopOpacity={0.3} />
                            <stop offset="95%" stopColor="#00e5ff" stopOpacity={0} />
                        </linearGradient>
                    </defs>
                    <XAxis dataKey="time" tick={false} axisLine={false} tickLine={false} />
                    <YAxis domain={[0, maxMb]} tick={{ fill: '#7ab0c8', fontSize: 10 }} axisLine={false} tickLine={false} />
                    <Tooltip
                        contentStyle={{ background: 'rgba(8,15,20,0.95)', border: '1px solid var(--nexus-border)', borderRadius: 6, fontSize: 12 }}
                        formatter={(v: number) => [`${(v / 1024).toFixed(1)} GB`, 'RAM']}
                    />
                    <Area type="monotone" dataKey="used" stroke="#00e5ff" strokeWidth={2} fill="url(#memGrad)" dot={false} isAnimationActive={false} />
                </AreaChart>
            </ResponsiveContainer>
        </div>
    );
};

export default MemoryChart;
