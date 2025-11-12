#!/usr/bin/env python3
"""
Analytics Library - Shared Python functions for data analysis and reporting
"""

import csv
import json
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


class SessionAnalytics:
    """Handle session analytics data"""

    def __init__(self, csv_path: Optional[str] = None):
        self.csv_path = csv_path or os.path.expanduser("~/.claude/session-logs/sessions.csv")

    def load_sessions(self) -> List[Dict]:
        """Load all sessions from CSV"""
        sessions = []

        if not os.path.exists(self.csv_path):
            return sessions

        with open(self.csv_path, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                sessions.append(row)

        return sessions

    def get_session(self, session_id: str) -> Optional[Dict]:
        """Get specific session by ID"""
        sessions = self.load_sessions()
        for session in sessions:
            if session['session_id'] == session_id:
                return session
        return None

    def get_project_sessions(self, project_name: str) -> List[Dict]:
        """Get all sessions for a specific project"""
        sessions = self.load_sessions()
        return [s for s in sessions if s['project'] == project_name]

    def calculate_project_totals(self, project_name: str) -> Dict:
        """Calculate aggregate statistics for a project"""
        sessions = self.get_project_sessions(project_name)

        if not sessions:
            return {}

        total_cost = sum(float(s.get('total_cost', 0)) for s in sessions)
        total_duration = sum(int(s.get('duration_seconds', 0)) for s in sessions)
        total_tokens = sum(int(s.get('total_tokens', 0)) for s in sessions)
        total_messages = sum(
            int(s.get('user_messages', 0)) + int(s.get('assistant_messages', 0))
            for s in sessions
        )

        return {
            'project': project_name,
            'session_count': len(sessions),
            'total_cost': round(total_cost, 4),
            'total_duration_seconds': total_duration,
            'total_duration_hours': round(total_duration / 3600, 2),
            'total_tokens': total_tokens,
            'total_messages': total_messages,
            'avg_cost_per_session': round(total_cost / len(sessions), 4),
            'avg_duration_per_session': round(total_duration / len(sessions), 0),
            'avg_tokens_per_session': round(total_tokens / len(sessions), 0),
        }

    def get_all_projects(self) -> List[str]:
        """Get list of unique projects"""
        sessions = self.load_sessions()
        projects = set(s['project'] for s in sessions if s.get('project'))
        return sorted(list(projects))

    def generate_summary_report(self) -> Dict:
        """Generate comprehensive summary report"""
        sessions = self.load_sessions()

        if not sessions:
            return {}

        projects = self.get_all_projects()
        project_stats = [self.calculate_project_totals(p) for p in projects]

        # Overall totals
        total_cost = sum(float(s.get('total_cost', 0)) for s in sessions)
        total_duration = sum(int(s.get('duration_seconds', 0)) for s in sessions)
        total_tokens = sum(int(s.get('total_tokens', 0)) for s in sessions)

        # Tool usage analysis
        tool_usage = {}
        for session in sessions:
            tools_used = session.get('tools_used', '')
            if tools_used:
                for tool_entry in tools_used.split('; '):
                    if ':' in tool_entry:
                        tool, count = tool_entry.split(':')
                        tool_usage[tool] = tool_usage.get(tool, 0) + int(count)

        top_tools = sorted(tool_usage.items(), key=lambda x: x[1], reverse=True)[:10]

        return {
            'total_sessions': len(sessions),
            'total_cost': round(total_cost, 4),
            'total_duration_hours': round(total_duration / 3600, 2),
            'total_tokens': total_tokens,
            'projects': len(projects),
            'project_statistics': project_stats,
            'top_tools': [{'tool': t, 'count': c} for t, c in top_tools],
            'avg_cost_per_session': round(total_cost / len(sessions), 4),
            'avg_duration_per_session': round(total_duration / len(sessions), 0),
        }


class SecurityLog:
    """Handle security event logging"""

    def __init__(self, log_path: Optional[str] = None):
        self.log_path = log_path or os.path.expanduser("~/.claude/session-logs/security.log")

    def get_events(self, session_id: Optional[str] = None) -> List[Dict]:
        """Parse security log and return events"""
        events = []

        if not os.path.exists(self.log_path):
            return events

        with open(self.log_path, 'r') as f:
            for line in f:
                # Parse format: [timestamp] [session_id] [event_type] message
                if line.startswith('['):
                    parts = line.split(']')
                    if len(parts) >= 4:
                        timestamp = parts[0].replace('[', '').strip()
                        sid = parts[1].replace('[', '').strip()
                        event_type = parts[2].replace('[', '').strip()
                        message = ']'.join(parts[3:]).strip()

                        if session_id is None or sid == session_id:
                            events.append({
                                'timestamp': timestamp,
                                'session_id': sid,
                                'event_type': event_type,
                                'message': message
                            })

        return events

    def count_by_type(self, session_id: Optional[str] = None) -> Dict[str, int]:
        """Count events by type"""
        events = self.get_events(session_id)
        counts = {}

        for event in events:
            event_type = event['event_type']
            counts[event_type] = counts.get(event_type, 0) + 1

        return counts


class QualityLog:
    """Handle quality event logging"""

    def __init__(self, log_path: Optional[str] = None):
        self.log_path = log_path or os.path.expanduser("~/.claude/session-logs/quality.log")

    def get_events(self, session_id: Optional[str] = None) -> List[Dict]:
        """Parse quality log and return events"""
        events = []

        if not os.path.exists(self.log_path):
            return events

        with open(self.log_path, 'r') as f:
            for line in f:
                # Same format as security log
                if line.startswith('['):
                    parts = line.split(']')
                    if len(parts) >= 4:
                        timestamp = parts[0].replace('[', '').strip()
                        sid = parts[1].replace('[', '').strip()
                        event_type = parts[2].replace('[', '').strip()
                        message = ']'.join(parts[3:]).strip()

                        if session_id is None or sid == session_id:
                            events.append({
                                'timestamp': timestamp,
                                'session_id': sid,
                                'event_type': event_type,
                                'message': message
                            })

        return events

    def count_by_type(self, session_id: Optional[str] = None) -> Dict[str, int]:
        """Count events by type"""
        events = self.get_events(session_id)
        counts = {}

        for event in events:
            event_type = event['event_type']
            counts[event_type] = counts.get(event_type, 0) + 1

        return counts


def generate_full_report(output_format: str = 'json') -> str:
    """Generate comprehensive analytics report

    Args:
        output_format: 'json' or 'markdown'

    Returns:
        Formatted report string
    """
    analytics = SessionAnalytics()
    security = SecurityLog()
    quality = QualityLog()

    report_data = {
        'generated_at': datetime.now().isoformat(),
        'session_analytics': analytics.generate_summary_report(),
        'security_events': security.count_by_type(),
        'quality_events': quality.count_by_type(),
    }

    if output_format == 'json':
        return json.dumps(report_data, indent=2)
    elif output_format == 'markdown':
        return format_markdown_report(report_data)
    else:
        raise ValueError(f"Unsupported format: {output_format}")


def format_markdown_report(data: Dict) -> str:
    """Format report data as markdown"""
    md = f"""# Claude Code Analytics Report

Generated: {data['generated_at']}

## Session Overview

- **Total Sessions**: {data['session_analytics'].get('total_sessions', 0)}
- **Total Cost**: ${data['session_analytics'].get('total_cost', 0)}
- **Total Duration**: {data['session_analytics'].get('total_duration_hours', 0)} hours
- **Total Tokens**: {data['session_analytics'].get('total_tokens', 0):,}
- **Projects**: {data['session_analytics'].get('projects', 0)}

## Top Tools Used

"""

    for tool in data['session_analytics'].get('top_tools', [])[:10]:
        md += f"- **{tool['tool']}**: {tool['count']} uses\n"

    md += "\n## Security Events\n\n"
    if data['security_events']:
        for event_type, count in sorted(data['security_events'].items(), key=lambda x: x[1], reverse=True):
            md += f"- **{event_type}**: {count}\n"
    else:
        md += "*No security events logged*\n"

    md += "\n## Quality Events\n\n"
    if data['quality_events']:
        for event_type, count in sorted(data['quality_events'].items(), key=lambda x: x[1], reverse=True):
            md += f"- **{event_type}**: {count}\n"
    else:
        md += "*No quality events logged*\n"

    md += "\n## Project Statistics\n\n"
    for project in data['session_analytics'].get('project_statistics', []):
        md += f"""### {project['project']}

- Sessions: {project['session_count']}
- Total Cost: ${project['total_cost']}
- Total Duration: {project['total_duration_hours']} hours
- Avg Cost/Session: ${project['avg_cost_per_session']}

"""

    return md


if __name__ == '__main__':
    # CLI interface for testing
    import sys

    if len(sys.argv) > 1:
        output_format = sys.argv[1] if sys.argv[1] in ['json', 'markdown'] else 'json'
    else:
        output_format = 'json'

    print(generate_full_report(output_format))
