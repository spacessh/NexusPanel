import React, { useState } from 'react';
import { Server, Play, Square, RotateCcw, Terminal, Folder, MoreVertical, Search } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export interface ServerData {
    id: string;
    name: string;
    status: 'online' | 'offline' | 'starting' | 'stopping';
    game: string;
    node: string;
    cpu: number;
    ram: number;
    ramMax: number;
    disk: number;
    diskMax: number;
    players?: number;
    maxPlayers?: number;
    ip: string;
    port: number;
}

const StatusBadge: React.FC<{ status: ServerData['status'] }> = ({ status }) => (
    <span className={`nexus-badge nexus-badge-${status}`}>
        <span className="nexus-badge-dot" />
        {status}
    </span>
);

const ServerRow: React.FC<{ server: ServerData; onAction: (id: string, action: string) => void }> = ({ server, onAction }) => {
    const navigate = useNavigate();
    return (
        <tr>
            <td>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <div style={{ width: 32, height: 32, background: 'rgba(0,255,136,0.1)', borderRadius: 8, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Server size={16} color="var(--nexus-green)" />
                    </div>
                    <div>
                        <div style={{ fontWeight: 600, fontSize: 13 }}>{server.name}</div>
                        <div style={{ fontSize: 11, color: 'var(--nexus-text2)' }}>{server.ip}:{server.port}</div>
                    </div>
                </div>
            </td>
            <td><StatusBadge status={server.status} /></td>
            <td style={{ color: 'var(--nexus-text2)', fontSize: 12 }}>{server.game}</td>
            <td>
                <div style={{ fontSize: 12 }}>
                    <div style={{ marginBottom: 4, color: 'var(--nexus-text2)' }}>{server.ram}/{server.ramMax} MB</div>
                    <div className="nexus-progress" style={{ width: 80 }}>
                        <div className="nexus-progress-bar" style={{ width: `${(server.ram / server.ramMax) * 100}%` }} />
                    </div>
                </div>
            </td>
            <td>
                <div style={{ fontSize: 12 }}>
                    <div style={{ marginBottom: 4, color: 'var(--nexus-text2)' }}>{server.cpu}%</div>
                    <div className="nexus-progress" style={{ width: 80 }}>
                        <div className="nexus-progress-bar" style={{ width: `${server.cpu}%` }} />
                    </div>
                </div>
            </td>
            <td style={{ color: 'var(--nexus-text2)', fontSize: 12 }}>{server.node}</td>
            <td>
                <div style={{ display: 'flex', gap: 6 }}>
                    {server.status === 'offline' ? (
                        <button className="nexus-btn nexus-btn-primary" style={{ padding: '5px 10px', fontSize: 12 }} onClick={() => onAction(server.id, 'start')}>
                            <Play size={12} /> Start
                        </button>
                    ) : (
                        <button className="nexus-btn nexus-btn-danger" style={{ padding: '5px 10px', fontSize: 12 }} onClick={() => onAction(server.id, 'stop')}>
                            <Square size={12} /> Stop
                        </button>
                    )}
                    <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 8px' }} onClick={() => onAction(server.id, 'restart')} title="Restart">
                        <RotateCcw size={12} />
                    </button>
                    <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 8px' }} onClick={() => navigate(`/servers/${server.id}/console`)} title="Console">
                        <Terminal size={12} />
                    </button>
                    <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 8px' }} onClick={() => navigate(`/servers/${server.id}/files`)} title="Files">
                        <Folder size={12} />
                    </button>
                </div>
            </td>
        </tr>
    );
};

const MOCK_SERVERS: ServerData[] = [
    { id: '1', name: 'Minecraft SMP', status: 'online',   game: 'Minecraft',    node: 'Node-EU-1', cpu: 34, ram: 2048, ramMax: 4096, disk: 12, diskMax: 50, players: 12, maxPlayers: 20, ip: '192.168.1.10', port: 25565 },
    { id: '2', name: 'CS2 Competitive', status: 'online', game: 'CS2',          node: 'Node-EU-2', cpu: 67, ram: 3200, ramMax: 8192, disk: 8,  diskMax: 30, players: 10, maxPlayers: 10, ip: '192.168.1.11', port: 27015 },
    { id: '3', name: 'Rust Survival',   status: 'offline', game: 'Rust',         node: 'Node-US-1', cpu: 0,  ram: 0,    ramMax: 8192, disk: 25, diskMax: 100, ip: '192.168.1.12', port: 28015 },
    { id: '4', name: 'Valheim World',   status: 'starting',game: 'Valheim',      node: 'Node-EU-1', cpu: 12, ram: 512,  ramMax: 4096, disk: 5,  diskMax: 30, ip: '192.168.1.13', port: 2456 },
    { id: '5', name: 'ARK Cluster',     status: 'online',  game: 'ARK',          node: 'Node-US-2', cpu: 89, ram: 14000,ramMax: 16384,disk: 80, diskMax: 200, players: 8, maxPlayers: 30, ip: '192.168.1.14', port: 7777 },
];

const ServerList: React.FC = () => {
    const [servers, setServers] = useState<ServerData[]>(MOCK_SERVERS);
    const [search, setSearch] = useState('');

    const handleAction = (id: string, action: string) => {
        setServers(prev => prev.map(s => {
            if (s.id !== id) return s;
            if (action === 'start')   return { ...s, status: 'starting' };
            if (action === 'stop')    return { ...s, status: 'stopping' };
            if (action === 'restart') return { ...s, status: 'starting' };
            return s;
        }));
    };

    const filtered = servers.filter(s =>
        s.name.toLowerCase().includes(search.toLowerCase()) ||
        s.game.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
                <h2 style={{ fontSize: 20, fontWeight: 700 }}>Servers</h2>
                <div style={{ display: 'flex', gap: 10 }}>
                    <div style={{ position: 'relative' }}>
                        <Search size={14} style={{ position: 'absolute', left: 10, top: '50%', transform: 'translateY(-50%)', color: 'var(--nexus-text2)' }} />
                        <input
                            className="nexus-input"
                            style={{ paddingLeft: 32, width: 220 }}
                            placeholder="Search servers..."
                            value={search}
                            onChange={e => setSearch(e.target.value)}
                        />
                    </div>
                    <button className="nexus-btn nexus-btn-primary">
                        <Server size={14} /> New Server
                    </button>
                </div>
            </div>
            <div className="nexus-card" style={{ padding: 0, overflow: 'hidden' }}>
                <table className="nexus-table">
                    <thead>
                        <tr>
                            <th>Server</th>
                            <th>Status</th>
                            <th>Game</th>
                            <th>RAM</th>
                            <th>CPU</th>
                            <th>Node</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {filtered.map(server => (
                            <ServerRow key={server.id} server={server} onAction={handleAction} />
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default ServerList;
