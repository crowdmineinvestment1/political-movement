/**
 * Security Monitoring Utility Functions
 * Handles data operations, authentication, and security-specific utilities
 */

class SecurityMonitor {
    constructor() {
        // In a real implementation, you would initialize Supabase here
        // this.supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        
        // For demo purposes, we'll use localStorage simulation
        this.initStorage();
    }
    
    initStorage() {
        // Initialize mock data structures if they don't exist
        if (!localStorage.getItem('security_assets')) {
            localStorage.setItem('security_assets', JSON.stringify([]));
        }
        if (!localStorage.getItem('security_events')) {
            localStorage.setItem('security_events', JSON.stringify([]));
        }
        if (!localStorage.getItem('network_traffic')) {
            localStorage.setItem('network_traffic', JSON.stringify([]));
        }
        if (!localStorage.getItem('user_consent')) {
            localStorage.setItem('user_consent', JSON.stringify({}));
        }
    }
    
    // Asset Management
    async getAssets() {
        try {
            // In real implementation: return await this.supabase.from('assets').select('*');
            const assets = JSON.parse(localStorage.getItem('security_assets') || '[]');
            return assets;
        } catch (error) {
            console.error('Error fetching assets:', error);
            return [];
        }
    }
    
    async addAsset(assetData) {
        try {
            const asset = {
                id: this.generateUUID(),
                ...assetData,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            };
            
            // In real implementation: return await this.supabase.from('assets').insert(asset);
            const assets = JSON.parse(localStorage.getItem('security_assets') || '[]');
            assets.push(asset);
            localStorage.setItem('security_assets', JSON.stringify(assets));
            
            return asset;
        } catch (error) {
            console.error('Error adding asset:', error);
            throw error;
        }
    }
    
    async updateAsset(id, updates) {
        try {
            const assets = JSON.parse(localStorage.getItem('security_assets') || '[]');
            const index = assets.findIndex(a => a.id === id);
            
            if (index !== -1) {
                assets[index] = {
                    ...assets[index],
                    ...updates,
                    updated_at: new Date().toISOString()
                };
                localStorage.setItem('security_assets', JSON.stringify(assets));
                return assets[index];
            }
            
            throw new Error('Asset not found');
        } catch (error) {
            console.error('Error updating asset:', error);
            throw error;
        }
    }
    
    async deleteAsset(id) {
        try {
            const assets = JSON.parse(localStorage.getItem('security_assets') || '[]');
            const filteredAssets = assets.filter(a => a.id !== id);
            localStorage.setItem('security_assets', JSON.stringify(filteredAssets));
            return true;
        } catch (error) {
            console.error('Error deleting asset:', error);
            throw error;
        }
    }
    
    // Security Events
    async logSecurityEvent(eventData) {
        try {
            const event = {
                id: this.generateUUID(),
                ...eventData,
                detected_at: new Date().toISOString()
            };
            
            // In real implementation: return await this.supabase.from('security_events').insert(event);
            const events = JSON.parse(localStorage.getItem('security_events') || '[]');
            events.push(event);
            localStorage.setItem('security_events', JSON.stringify(events));
            
            return event;
        } catch (error) {
            console.error('Error logging security event:', error);
            throw error;
        }
    }
    
    async getSecurityEvents(filters = {}) {
        try {
            // In real implementation: let query = this.supabase.from('security_events').select('*');
            let events = JSON.parse(localStorage.getItem('security_events') || '[]');
            
            // Apply filters
            if (filters.severity) {
                events = events.filter(e => e.severity === filters.severity);
            }
            if (filters.event_type) {
                events = events.filter(e => e.event_type === filters.event_type);
            }
            if (filters.asset_id) {
                events = events.filter(e => e.asset_id === filters.asset_id);
            }
            if (filters.limit) {
                events = events.slice(0, parseInt(filters.limit));
            }
            
            // Sort by date descending
            events.sort((a, b) => new Date(b.detected_at) - new Date(a.detected_at));
            
            return events;
        } catch (error) {
            console.error('Error fetching security events:', error);
            return [];
        }
    }
    
    // Network Traffic
    async logNetworkTraffic(trafficData) {
        try {
            const traffic = {
                id: this.generateUUID(),
                ...trafficData,
                captured_at: new Date().toISOString()
            };
            
            // In real implementation: return await this.supabase.from('network_traffic').insert(traffic);
            const trafficLogs = JSON.parse(localStorage.getItem('network_traffic') || '[]');
            trafficLogs.push(traffic);
            localStorage.setItem('network_traffic', JSON.stringify(trafficLogs));
            
            return traffic;
        } catch (error) {
            console.error('Error logging network traffic:', error);
            throw error;
        }
    }
    
    async getNetworkTraffic(filters = {}) {
        try {
            // In real implementation: let query = this.supabase.from('network_traffic').select('*');
            let traffic = JSON.parse(localStorage.getItem('network_traffic') || '[]');
            
            // Apply filters
            if (filters.source_ip) {
                traffic = traffic.filter(t => t.source_ip === filters.source_ip);
            }
            if (filters.destination_ip) {
                traffic = traffic.filter(t => t.destination_ip === filters.destination_ip);
            }
            if (filters.is_malicious !== undefined) {
                traffic = traffic.filter(t => t.is_malicious === filters.is_malicious);
            }
            if (filters.protocol) {
                traffic = traffic.filter(t => t.protocol === filters.protocol);
            }
            if (filters.limit) {
                traffic = traffic.slice(0, parseInt(filters.limit));
            }
            
            // Sort by timestamp descending
            traffic.sort((a, b) => new Date(b.captured_at) - new Date(a.captured_at));
            
            return traffic;
        } catch (error) {
            console.error('Error fetching network traffic:', error);
            return [];
        }
    }
    
    // Consent Management (Critical for legal compliance)
    async recordConsent(userId, consentType, granted) {
        try {
            const consents = JSON.parse(localStorage.getItem('user_consent') || '{}');
            
            if (!consents[userId]) {
                consents[userId] = {};
            }
            
            consents[userId][consentType] = {
                granted: granted,
                timestamp: new Date().toISOString(),
                version: '1.0'
            };
            
            localStorage.setItem('user_consent', JSON.stringify(consents));
            
            return true;
        } catch (error) {
            console.error('Error recording consent:', error);
            throw error;
        }
    }
    
    async hasConsent(userId, consentType) {
        try {
            const consents = JSON.parse(localStorage.getItem('user_consent') || '{}');
            return consents[userId] && 
                   consents[userId][consentType] && 
                   consents[userId][consentType].granted === true;
        } catch (error) {
            console.error('Error checking consent:', error);
            return false;
        }
    }
    
    // Utility Functions
    generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    
    // Data anonymization for privacy compliance
    anonymizeIP(ip) {
        if (!ip) return null;
        try {
            // For IPv4, zero out last octet
            if (ip.includes('.')) {
                const parts = ip.split('.');
                parts[3] = '0';
                return parts.join('.');
            }
            // For IPv6, zero out last 4 groups
            if (ip.includes(':')) {
                const parts = ip.split(':');
                for (let i = Math.max(0, parts.length - 4); i < parts.length; i++) {
                    parts[i] = '0';
                }
                return parts.join(':');
            }
            return ip;
        } catch (error) {
            console.error('Error anonymizing IP:', error);
            return null;
        }
    }
    
    hashData(data) {
        // Simple hash for demo - in production use crypto.subtle or similar
        let hash = 0;
        if (data.length === 0) return hash;
        for (let i = 0; i < data.length; i++) {
            const char = data.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32bit integer
        }
        return Math.abs(hash);
    }
    
    // Compliance checking
    async checkCompliance(assetId, standard) {
        try {
            // This would integrate with actual compliance checking engines
            // For demo, return mock compliance data
            return {
                asset_id: assetId,
                standard: standard,
                compliant: Math.random() > 0.3, // Random for demo
                score: Math.floor(Math.random() * 100),
                last_checked: new Date().toISOString(),
                findings: Math.random() > 0.5 ? [] : [
                    {
                        id: 'CFG-001',
                        description: 'Default password detected',
                        severity: 'medium',
                        remediation: 'Change default credentials'
                    }
                ]
            };
        } catch (error) {
            console.error('Error checking compliance:', error);
            throw error;
        }
    }
    
    // Threat intelligence integration
    async checkThreatIntelligence(indicator) {
        try {
            // This would integrate with threat intelligence feeds
            // For demo, return mock threat intelligence
            const threatMap = {
                '185.220.101.150': { threat: true, type: 'malicious_ip', confidence: 85 },
                'known-bad-domain.com': { threat: true, type: 'malicious_domain', confidence: 92 },
                'malware-hash-123abc': { threat: true, type: 'malware_hash', confidence: 78 }
            };
            
            return threatMap[indicator] || { threat: false, type: 'unknown', confidence: 0 };
        } catch (error) {
            console.error('Error checking threat intelligence:', error);
            return { threat: false, type: 'error', confidence: 0 };
        }
    }
}

// Initialize global security monitor instance
const securityMonitor = new SecurityMonitor();

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { SecurityMonitor, securityMonitor };
}