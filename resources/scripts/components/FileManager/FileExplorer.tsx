import React, { useState } from 'react';
import { Folder, File, ChevronRight, Upload, Plus, Trash2, Edit2, Download, ArrowLeft } from 'lucide-react';

interface FileItem {
    name: string;
    type: 'file' | 'dir';
    size?: number;
    modified?: string;
    children?: FileItem[];
}

const MOCK_FILES: FileItem[] = [
    { name: 'config',  type: 'dir', modified: '2026-04-10', children: [
        { name: 'server.properties', type: 'file', size: 2048, modified: '2026-04-10' },
        { name: 'ops.json',          type: 'file', size: 512,  modified: '2026-04-09' },
        { name: 'whitelist.json',    type: 'file', size: 256,  modified: '2026-04-08' },
    ]},
    { name: 'plugins', type: 'dir', modified: '2026-04-09', children: [
        { name: 'EssentialsX.jar',   type: 'file', size: 4194304, modified: '2026-04-01' },
        { name: 'WorldEdit.jar',     type: 'file', size: 3145728, modified: '2026-03-15' },
    ]},
    { name: 'world',   type: 'dir', modified: '2026-04-10', children: [] },
    { name: 'logs',    type: 'dir', modified: '2026-04-10', children: [
        { name: 'latest.log',        type: 'file', size: 102400, modified: '2026-04-10' },
    ]},
    { name: 'server.jar', type: 'file', size: 52428800, modified: '2026-04-01' },
    { name: 'eula.txt',   type: 'file', size: 128,      modified: '2026-04-01' },
];

const formatSize = (bytes?: number): string => {
    if (!bytes) return '—';
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1048576) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / 1048576).toFixed(1)} MB`;
};

const FileRow: React.FC<{
    item: FileItem;
    onOpen: (item: FileItem) => void;
    selected: boolean;
    onSelect: () => void;
}> = ({ item, onOpen, selected, onSelect }) => (
    <div
        className={`nexus-file-row ${selected ? 'selected' : ''}`}
        onClick={onSelect}
        onDoubleClick={() => item.type === 'dir' && onOpen(item)}
    >
        <div style={{ color: item.type === 'dir' ? 'var(--nexus-cyan)' : 'var(--nexus-text2)' }}>
            {item.type === 'dir' ? <Folder size={16} /> : <File size={16} />}
        </div>
        <span style={{ flex: 1, fontSize: 13 }}>{item.name}</span>
        <span style={{ fontSize: 11, color: 'var(--nexus-text2)', width: 80, textAlign: 'right' }}>{formatSize(item.size)}</span>
        <span style={{ fontSize: 11, color: 'var(--nexus-text2)', width: 100, textAlign: 'right' }}>{item.modified ?? '—'}</span>
    </div>
);

const FileExplorer: React.FC<{ serverId?: string }> = ({ serverId }) => {
    const [path, setPath] = useState<string[]>([]);
    const [selected, setSelected] = useState<string | null>(null);
    const [currentFiles, setCurrentFiles] = useState<FileItem[]>(MOCK_FILES);

    const navigateTo = (item: FileItem) => {
        if (item.type !== 'dir') return;
        setPath(prev => [...prev, item.name]);
        setCurrentFiles(item.children ?? []);
        setSelected(null);
    };

    const navigateBack = () => {
        if (path.length === 0) return;
        setPath(prev => prev.slice(0, -1));
        setCurrentFiles(MOCK_FILES); // simplified — real impl would track stack
        setSelected(null);
    };

    return (
        <div className="nexus-card" style={{ padding: 0, overflow: 'hidden' }}>
            {/* Toolbar */}
            <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--nexus-border)', display: 'flex', alignItems: 'center', gap: 10 }}>
                <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 8px' }} onClick={navigateBack} disabled={path.length === 0}>
                    <ArrowLeft size={14} />
                </button>
                {/* Breadcrumb */}
                <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 4, fontSize: 13, color: 'var(--nexus-text2)' }}>
                    <span style={{ cursor: 'pointer', color: 'var(--nexus-green)' }} onClick={() => { setPath([]); setCurrentFiles(MOCK_FILES); }}>
                        /home/server
                    </span>
                    {path.map((p, i) => (
                        <React.Fragment key={i}>
                            <ChevronRight size={12} />
                            <span>{p}</span>
                        </React.Fragment>
                    ))}
                </div>
                <div style={{ display: 'flex', gap: 6 }}>
                    <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 10px', fontSize: 12 }}>
                        <Upload size={12} /> Upload
                    </button>
                    <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 10px', fontSize: 12 }}>
                        <Plus size={12} /> New File
                    </button>
                    <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 10px', fontSize: 12 }}>
                        <Folder size={12} /> New Folder
                    </button>
                    {selected && (
                        <>
                            <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 10px', fontSize: 12 }}>
                                <Edit2 size={12} /> Edit
                            </button>
                            <button className="nexus-btn nexus-btn-ghost" style={{ padding: '5px 10px', fontSize: 12 }}>
                                <Download size={12} /> Download
                            </button>
                            <button className="nexus-btn nexus-btn-danger" style={{ padding: '5px 10px', fontSize: 12 }}>
                                <Trash2 size={12} /> Delete
                            </button>
                        </>
                    )}
                </div>
            </div>
            {/* Header */}
            <div style={{ display: 'flex', padding: '8px 12px', borderBottom: '1px solid var(--nexus-border)', fontSize: 11, color: 'var(--nexus-text2)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.8px' }}>
                <span style={{ flex: 1 }}>Name</span>
                <span style={{ width: 80, textAlign: 'right' }}>Size</span>
                <span style={{ width: 100, textAlign: 'right' }}>Modified</span>
            </div>
            {/* Files */}
            <div style={{ padding: '8px' }}>
                {currentFiles.length === 0 ? (
                    <div style={{ textAlign: 'center', padding: '40px', color: 'var(--nexus-text2)', fontSize: 13 }}>
                        Empty directory
                    </div>
                ) : (
                    currentFiles.map(item => (
                        <FileRow
                            key={item.name}
                            item={item}
                            onOpen={navigateTo}
                            selected={selected === item.name}
                            onSelect={() => setSelected(item.name)}
                        />
                    ))
                )}
            </div>
        </div>
    );
};

export default FileExplorer;
