import React, { useEffect, useState } from 'react';
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, ReferenceLine } from 'recharts';
import { Cpu } from 'lucide-react';

interface DataPoint { time: string; value: number; }

const CPUChart: React.FC<{ serverId?: string }> = ({ serverId }) => {
    const [data, setData] = useState<DataPoint[]>(() =>
        Array.from({ length: 30 }, (_, i) => ({
            time: `${i}s`,
            value: Math.floor(Math.random() * 50 + 20),
        }))
    );
    const current = data[data.length - 1]?.value ?? 0;

    useEffect(() => {
        let tick = 30;
        const interval = setInterval(() => {
            setData(prev => [...prev.slice(-29), { time: `${tick++}s`, value: Math.floor(Math.random() * 50 + 20) }]);
        }, 1000);
        return () => clearInterval(interval);
    }, []);

    const color = current > 80 ? 'var(--nexus-red)' : current > 60 ? 'var(--nexus-yellow)' : 'var(--nexus-green)';

    return (
        <div className="nexus-card">
            <div className="nexus-card-header">
                <span className="nexus-card-title"><Cpu size={14} /> CPU Usage</span>
                <span style={{ fontSize: 22, fontWeight: 700, color, fontFamily: 'monospace' }}>{current}%</span>
            </div>
            <ResponsiveContainer width="100%" height={120}>
                <LineChart data={data} margin={{ top: 5, right: 5, bottom: 0, left: -30 }}>
                    <XAxis dataKey="time" tick={false} axisLine={false} tickLine={false} />
                    <YAxis domain={[0, 100]} tick={{ fill: '#7ab0c8', fontSize: 10 }} axisLine={false} tickLine={false} />
                    <Tooltip
                        contentStyle={{ background: 'rgba(8,15,20,0.95)', border: '1px solid var(--nexus-border)', borderRadius: 6, fontSize: 12 }}
                        labelStyle={{ color: 'var(--nexus-text2)' }}
                        itemStyle={{ color }}
                    />
                    <ReferenceLine y={80} stroke="rgba(255,68,102,0.3)" strokeDasharray="3 3" />
                    <Line type="monotone" dataKey="value" stroke={color} strokeWidth={2} dot={false} isAnimationActive={false} />
                </LineChart>
            </ResponsiveContainer>
        </div>
    );
};

export default CPUChart;
