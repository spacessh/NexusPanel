import React, { useState } from 'react';
import AnimatedBackground from '@/components/Dashboard/AnimatedBackground';

const LoginPage: React.FC = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setTimeout(() => setLoading(false), 1500);
    };

    return (
        <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
            <AnimatedBackground />
            <div style={{ position: 'relative', zIndex: 10, width: '100%', maxWidth: 400, padding: '0 20px' }}>
                {/* Logo */}
                <div style={{ textAlign: 'center', marginBottom: 40 }}>
                    <div style={{
                        width: 64, height: 64, margin: '0 auto 16px',
                        background: 'linear-gradient(135deg, #00ff88, #00e5ff)',
                        borderRadius: 16, display: 'flex', alignItems: 'center', justifyContent: 'center',
                        fontSize: 28, boxShadow: '0 0 40px rgba(0,255,136,0.5)',
                        animation: 'logoPulse 3s ease-in-out infinite',
                    }}>
                        ⚡
                    </div>
                    <h1 style={{
                        fontSize: 32, fontWeight: 800, letterSpacing: 2,
                        background: 'linear-gradient(135deg, #00ff88, #00e5ff)',
                        WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
                    }}>
                        NEXUSPANEL
                    </h1>
                    <p style={{ color: 'var(--nexus-text2)', fontSize: 13, marginTop: 6 }}>
                        Ultimate Server Management Platform
                    </p>
                </div>

                {/* Card */}
                <div className="nexus-card nexus-glow-box" style={{ padding: 32 }}>
                    <h2 style={{ fontSize: 18, fontWeight: 600, marginBottom: 24, textAlign: 'center' }}>Sign In</h2>
                    <form onSubmit={handleSubmit} style={{ display: 'grid', gap: 16 }}>
                        <div>
                            <label style={{ display: 'block', fontSize: 12, color: 'var(--nexus-text2)', marginBottom: 6, textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                                Email
                            </label>
                            <input
                                className="nexus-input"
                                type="email"
                                placeholder="admin@nexuspanel.io"
                                value={email}
                                onChange={e => setEmail(e.target.value)}
                                required
                            />
                        </div>
                        <div>
                            <label style={{ display: 'block', fontSize: 12, color: 'var(--nexus-text2)', marginBottom: 6, textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                                Password
                            </label>
                            <input
                                className="nexus-input"
                                type="password"
                                placeholder="••••••••"
                                value={password}
                                onChange={e => setPassword(e.target.value)}
                                required
                            />
                        </div>
                        <button
                            className="nexus-btn nexus-btn-primary"
                            type="submit"
                            disabled={loading}
                            style={{ width: '100%', justifyContent: 'center', padding: '12px', fontSize: 14, marginTop: 8 }}
                        >
                            {loading ? '⟳ Signing in...' : '→ Sign In'}
                        </button>
                    </form>
                    <div style={{ textAlign: 'center', marginTop: 20, fontSize: 12, color: 'var(--nexus-text2)' }}>
                        Forgot password? <a href="#" style={{ color: 'var(--nexus-green)' }}>Reset it</a>
                    </div>
                </div>

                <div style={{ textAlign: 'center', marginTop: 20, fontSize: 11, color: 'var(--nexus-text2)', opacity: 0.5 }}>
                    NexusPanel v1.0.0 — Powered by open source
                </div>
            </div>
        </div>
    );
};

export default LoginPage;
