import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AppLayout from '@/components/Layout/AppLayout';
import LoginPage from '@/pages/LoginPage';
import Dashboard from '@/pages/Dashboard';
import ServerPage from '@/pages/ServerPage';
import ServerList from '@/components/Servers/ServerList';
import '@/styles/theme.scss';

const App: React.FC = () => (
    <BrowserRouter>
        <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/" element={<AppLayout />}>
                <Route index element={<Dashboard />} />
                <Route path="servers" element={<ServerList />} />
                <Route path="servers/:id" element={<ServerPage />} />
                <Route path="servers/:id/console" element={<ServerPage />} />
                <Route path="servers/:id/files" element={<ServerPage />} />
                <Route path="*" element={<Navigate to="/" replace />} />
            </Route>
        </Routes>
    </BrowserRouter>
);

export default App;
