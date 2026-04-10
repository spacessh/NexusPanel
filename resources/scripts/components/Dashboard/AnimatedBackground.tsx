import React from 'react';

const AnimatedBackground: React.FC = () => (
    <>
        <div className="nexus-bg-animated">
            {Array.from({ length: 18 }, (_, i) => (
                <div key={i} className="nexus-band" />
            ))}
            <div className="nexus-band-glow" />
            <div className="nexus-band-glow" />
            <div className="nexus-band-glow" />
        </div>
        <div className="nexus-grid-overlay" />
    </>
);

export default AnimatedBackground;
