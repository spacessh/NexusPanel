import React, { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { Wifi } from 'lucide-react';

interface DataPoint { time: string; rx: number; tx: number; }

const NetworkChart: React.FC = () => {
    const [data, setData] = useState<DataPoint[]>(() =>
        Array.from({ length: 20 }, (_, i) => ({
            time: `${i}s`,
            rx: Math.floor(Math.random() * 500),
            tx: Math.floor(Math.random() * 200),
        }))
    );

    useEffect(() => {
        let tick = 20;
        const interval = setInterval(() => {
            setData(prev => [...prev.slice(-19), {
                time: `${tick++}s`,
                rx: Math.floor(Math.random() * 500),
                tx: Math.floor(Math.random() * 200),
            }]);
        }, 1500);
        return () => clearInterval(interval);
    }, []);

    const last = data[data.length - 1];

    return (
        <div className="nexus-card">
            <div className="nexus-card-header">
                <span className="nexus-card-title"><Wifi size={14} /> Network I/O</span>
                <div style={{ display: 'flex', gap: 16, fontSize: 12 }}>
                    <span style={{ color: 'var(--nexus-green)' }}>↓ {last?.rx ?? 0} KB/s</span>
                    <span style={{ color: 'var(--nexus-purple)' }}>↑ {last?.tx ?? 0} KB/s</span>
                </div>
            </div>
            <ResponsiveContainer width="100%" height={120}>
                <BarChart data={data} margin={{ top: 5, right: 5, bottom: 0, left: -30 }} barSize={6} barGap={2}>
                    <XAxis dataKey="time" tick={false} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fill: '#7ab0c8', fontSize: 10 }} axisLine={false} tickLine={false} />
                    <Tooltip
                        contentStyle={{ background: 'rgba(8,15,20,0.95)', border: '1px solid var(--nexus-border)', borderRadius: 6, fontSize: 12 }}
                        formatter={(v: number, name: string) => [`${v} KB/s`, name === 'rx' ? 'Download' : 'Upload']}
                    />
                    <Bar dataKey="rx" fill="#00ff88" opacity={0.8} radius={[2, 2, 0, 0]} />
                    <Bar dataKey="tx" fill="#9966ff" opacity={0.8} radius={[2, 2, 0, 0]} />
                </BarChart>
            </ResponsiveContainer>
        </div>
    );
};

export default NetworkChart;
