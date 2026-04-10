import React, { useState, useEffect, useRef } from 'react';
import { Terminal, Send, Trash2, Download } from 'lucide-react';

interface LogLine {
    id: number;
    time: string;
    level: 'info' | 'warn' | 'error' | 'success' | 'system';
    message: string;
}

const LEVEL_COLORS: Record<LogLine['level'], string> = {
    info:    'var(--nexus-text)',
    warn:    'var(--nexus-yellow)',
    error:   'var(--nexus-red)',
    success: 'var(--nexus-green)',
    system:  'var(--nexus-cyan)',
};

const MOCK_LOGS: LogLine[] = [
    { id: 1,  time: '10:00:01', level: 'system',  message: '[NexusPanel] Server starting...' },
    { id: 2,  time: '10:00:02', level: 'info',    message: '[Server] Loading world data...' },
    { id: 3,  time: '10:00:03', level: 'success', message: '[Server] World loaded successfully.' },
    { id: 4,  time: '10:00:05', level: 'info',    message: '[Server] Listening on 0.0.0.0:25565' },
    { id: 5,  time: '10:00:10', level: 'success', message: '[Server] Done! For help, type "help"' },
    { id: 6,  time: '10:01:22', level: 'info',    message: '[Server] Player Steve joined the game' },
    { id: 7,  time: '10:02:45', level: 'warn',    message: '[Server] Can\'t keep up! Is the server overloaded?' },
    { id: 8,  time: '10:03:01', level: 'info',    message: '[Server] Player Alex joined the game' },
    { id: 9,  time: '10:04:15', level: 'error',   message: '[Server] Failed to save chunk [12, 8]' },
    { id: 10, time: '10:05:00', level: 'info',    message: '[Server] Autosave complete.' },
];

const ServerConsole: React.FC<{ serverId?: string }> = ({ serverId }) => {
    const [logs, setLogs] = useState<LogLine[]>(MOCK_LOGS);
    const [input, setInput] = useState('');
    const [history, setHistory] = useState<string[]>([]);
    const [historyIdx, setHistoryIdx] = useState(-1);
    const bottomRef = useRef<HTMLDivElement>(null);
    const inputRef = useRef<HTMLInputElement>(null);

    useEffect(() => {
        bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, [logs]);

    // Simulate incoming logs
    useEffect(() => {
        const messages = [
            { level: 'info' as const,    message: '[Server] Tick processing...' },
            { level: 'success' as const, message: '[Server] Chunk saved successfully.' },
            { level: 'warn' as const,    message: '[Server] Memory usage high: 85%' },
        ];
        let i = 0;
        const interval = setInterval(() => {
            const msg = messages[i % messages.length];
            setLogs(prev => [...prev, {
                id: Date.now(),
                time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
                ...msg,
            }]);
            i++;
        }, 5000);
        return () => clearInterval(interval);
    }, []);

    const sendCommand = () => {
        if (!input.trim()) return;
        const cmd = input.trim();
        setLogs(prev => [...prev, {
            id: Date.now(),
            time: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
            level: 'system',
            message: `> ${cmd}`,
        }]);
        setHistory(prev => [cmd, ...prev.slice(0, 49)]);
        setHistoryIdx(-1);
        setInput('');
    };

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter') { sendCommand(); return; }
        if (e.key === 'ArrowUp') {
            const idx = Math.min(historyIdx + 1, history.length - 1);
            setHistoryIdx(idx);
            setInput(history[idx] ?? '');
        }
        if (e.key === 'ArrowDown') {
            const idx = Math.max(historyIdx - 1, -1);
            setHistoryIdx(idx);
            setInput(idx === -1 ? '' : history[idx]);
        }
    };

    const downloadLogs = () => {
        const text = logs.map(l => `[${l.time}] [${l.level.toUpperCase()}] ${l.message}`).join('\n');
        const blob = new Blob([text], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url; a.download = `server-${serverId ?? 'console'}-logs.txt`;
        a.click(); URL.revokeObjectURL(url);
    };

    return (
        <div className="nexus-console">
            <div className="nexus-console-header">
                <Terminal size={14} color="var(--nexus-green)" />
                <span>Console — Server {serverId ?? '?'}</span>
                <div style={{ marginLeft: 'auto', display: 'flex', gap: 8 }}>
                    <button className="nexus-btn nexus-btn-ghost" style={{ padding: '3px 8px', fontSize: 11 }} onClick={downloadLogs}>
                        <Download size={12} /> Export
                    </button>
                    <button className="nexus-btn nexus-btn-ghost" style={{ padding: '3px 8px', fontSize: 11 }} onClick={() => setLogs([])}>
                        <Trash2 size={12} /> Clear
                    </button>
                </div>
            </div>
            <div className="nexus-console-body" onClick={() => inputRef.current?.focus()}>
                {logs.map(log => (
                    <div key={log.id} style={{ marginBottom: 2 }}>
                        <span style={{ color: 'var(--nexus-text2)', marginRight: 8, fontSize: 11 }}>[{log.time}]</span>
                        <span style={{ color: LEVEL_COLORS[log.level] }}>{log.message}</span>
                    </div>
                ))}
                <div ref={bottomRef} />
            </div>
            <div className="nexus-console-input">
                <span style={{ color: 'var(--nexus-green)', fontSize: 13 }}>$</span>
                <input
                    ref={inputRef}
                    value={input}
                    onChange={e => setInput(e.target.value)}
                    onKeyDown={handleKeyDown}
                    placeholder="Enter command..."
                    autoComplete="off"
                    spellCheck={false}
                />
                <button className="nexus-btn nexus-btn-primary" style={{ padding: '5px 12px', fontSize: 12 }} onClick={sendCommand}>
                    <Send size={12} />
                </button>
            </div>
        </div>
    );
};

export default ServerConsole;
