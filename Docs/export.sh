#!/bin/bash

# WorkOut Log Documentation Export Script
# Converts markdown documentation to PDF using pandoc, with HTML fallback

set -euo pipefail

# Configuration
DOCS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$DOCS_DIR/.." && pwd)"
OUTPUT_DIR="$DOCS_DIR/exports"
DATE=$(date +"%Y-%m-%d")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if pandoc is available
check_pandoc() {
    if command -v pandoc >/dev/null 2>&1; then
        local version=$(pandoc --version | head -n1)
        log_info "Found $version"
        return 0
    else
        log_warn "Pandoc not found. Installing via Homebrew..."
        if command -v brew >/dev/null 2>&1; then
            brew install pandoc
            if command -v pandoc >/dev/null 2>&1; then
                log_success "Pandoc installed successfully"
                return 0
            else
                log_error "Failed to install pandoc"
                return 1
            fi
        else
            log_error "Homebrew not found. Please install pandoc manually: https://pandoc.org/installing.html"
            return 1
        fi
    fi
}

# Check if required LaTeX packages are available for PDF generation
check_latex() {
    if command -v pdflatex >/dev/null 2>&1; then
        log_info "LaTeX found - PDF generation available"
        return 0
    else
        log_warn "LaTeX not found - will use HTML output only"
        log_info "To enable PDF output, install LaTeX: brew install --cask mactex"
        return 1
    fi
}

# Create output directory
setup_output_dir() {
    mkdir -p "$OUTPUT_DIR"
    log_info "Output directory: $OUTPUT_DIR"
}

# Export single markdown file
export_markdown() {
    local input_file="$1"
    local output_name="$2"
    local has_latex="$3"

    log_info "Exporting: $(basename "$input_file")"

    if [[ "$has_latex" == "true" ]]; then
        # Generate PDF with pandoc
        pandoc "$input_file" \
            --from markdown \
            --to pdf \
            --pdf-engine=pdflatex \
            --variable geometry:margin=1in \
            --variable fontsize:11pt \
            --variable documentclass:article \
            --variable linkcolor:blue \
            --toc \
            --number-sections \
            --output "$OUTPUT_DIR/${output_name}_${DATE}.pdf"

        log_success "PDF created: ${output_name}_${DATE}.pdf"
    fi

    # Always generate HTML as fallback
    pandoc "$input_file" \
        --from markdown \
        --to html5 \
        --standalone \
        --css "github.css" \
        --toc \
        --number-sections \
        --metadata title="$(basename "$input_file" .md)" \
        --output "$OUTPUT_DIR/${output_name}_${DATE}.html"

    log_success "HTML created: ${output_name}_${DATE}.html"
}

# Export all ADRs as combined document
export_combined_adrs() {
    local has_latex="$1"
    local adr_dir="$PROJECT_ROOT/ADR"
    local combined_file="$OUTPUT_DIR/combined_adrs.md"

    if [[ ! -d "$adr_dir" ]]; then
        log_warn "ADR directory not found: $adr_dir"
        return
    fi

    log_info "Creating combined ADR document..."

    # Create combined markdown file
    cat > "$combined_file" << EOF
# WorkOut Log - Architecture Decision Records

Generated on: $(date +"%Y-%m-%d %H:%M:%S")

This document contains all Architecture Decision Records (ADRs) for the WorkOut Log project.

---

EOF

    # Append each ADR
    for adr_file in "$adr_dir"/ADR-*.md; do
        if [[ -f "$adr_file" ]]; then
            echo "" >> "$combined_file"
            cat "$adr_file" >> "$combined_file"
            echo -e "\n---\n" >> "$combined_file"
        fi
    done

    # Export combined ADRs
    export_markdown "$combined_file" "all_adrs" "$has_latex"

    # Clean up temporary file
    rm "$combined_file"
}

# Export comprehensive documentation package
export_complete_docs() {
    local has_latex="$1"
    local temp_file="$OUTPUT_DIR/complete_documentation.md"

    log_info "Creating complete documentation package..."

    # Create comprehensive document
    cat > "$temp_file" << EOF
# WorkOut Log - Complete Documentation

**Project**: WorkOut Log - iOS Workout Tracking App
**Architecture**: Clean Architecture with SwiftUI + SwiftData
**Generated**: $(date +"%Y-%m-%d %H:%M:%S")

---

EOF

    # Add README
    if [[ -f "$PROJECT_ROOT/README_NEW.md" ]]; then
        echo -e "\n# Project Overview\n" >> "$temp_file"
        cat "$PROJECT_ROOT/README_NEW.md" >> "$temp_file"
        echo -e "\n---\n" >> "$temp_file"
    fi

    # Add Developer Guide
    if [[ -f "$DOCS_DIR/workout_log_guide.md" ]]; then
        echo -e "\n# Developer Guide\n" >> "$temp_file"
        cat "$DOCS_DIR/workout_log_guide.md" >> "$temp_file"
        echo -e "\n---\n" >> "$temp_file"
    fi

    # Add all ADRs
    for adr_file in "$PROJECT_ROOT/ADR"/ADR-*.md; do
        if [[ -f "$adr_file" ]]; then
            echo -e "\n# $(basename "$adr_file" .md | tr '-' ' ' | sed 's/ADR /ADR-/')\n" >> "$temp_file"
            cat "$adr_file" >> "$temp_file"
            echo -e "\n---\n" >> "$temp_file"
        fi
    done

    # Export complete documentation
    export_markdown "$temp_file" "complete_documentation" "$has_latex"

    # Clean up
    rm "$temp_file"
}

# Add CSS for better HTML styling
create_css() {
    cat > "$OUTPUT_DIR/github.css" << 'EOF'
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    line-height: 1.6;
    color: #24292e;
    max-width: 1000px;
    margin: 0 auto;
    padding: 20px;
}

h1, h2, h3, h4, h5, h6 {
    margin-top: 24px;
    margin-bottom: 16px;
    font-weight: 600;
    line-height: 1.25;
}

h1 { border-bottom: 1px solid #eaecef; padding-bottom: 10px; }
h2 { border-bottom: 1px solid #eaecef; padding-bottom: 8px; }

code {
    background-color: rgba(27,31,35,0.05);
    border-radius: 3px;
    font-size: 85%;
    margin: 0;
    padding: 0.2em 0.4em;
}

pre {
    background-color: #f6f8fa;
    border-radius: 6px;
    font-size: 85%;
    line-height: 1.45;
    overflow: auto;
    padding: 16px;
}

blockquote {
    border-left: 4px solid #dfe2e5;
    color: #6a737d;
    margin: 0;
    padding: 0 16px;
}

table {
    border-collapse: collapse;
    width: 100%;
}

th, td {
    border: 1px solid #dfe2e5;
    padding: 6px 13px;
    text-align: left;
}

th {
    background-color: #f6f8fa;
    font-weight: 600;
}
EOF
}

# Main execution
main() {
    log_info "WorkOut Log Documentation Export"
    log_info "================================"

    # Setup
    setup_output_dir
    create_css

    # Check dependencies
    local has_pandoc="false"
    local has_latex="false"

    if check_pandoc; then
        has_pandoc="true"
        if check_latex; then
            has_latex="true"
        fi
    else
        log_error "Cannot proceed without pandoc. Exiting."
        exit 1
    fi

    # Export individual documents
    if [[ -f "$PROJECT_ROOT/README_NEW.md" ]]; then
        export_markdown "$PROJECT_ROOT/README_NEW.md" "readme" "$has_latex"
    fi

    if [[ -f "$DOCS_DIR/workout_log_guide.md" ]]; then
        export_markdown "$DOCS_DIR/workout_log_guide.md" "developer_guide" "$has_latex"
    fi

    # Export individual ADRs
    for adr_file in "$PROJECT_ROOT/ADR"/ADR-*.md; do
        if [[ -f "$adr_file" ]]; then
            local adr_name=$(basename "$adr_file" .md | tr '[:upper:]' '[:lower:]')
            export_markdown "$adr_file" "$adr_name" "$has_latex"
        fi
    done

    # Export combined documents
    export_combined_adrs "$has_latex"
    export_complete_docs "$has_latex"

    # Summary
    log_info ""
    log_success "Documentation export complete!"
    log_info "Output directory: $OUTPUT_DIR"
    log_info "Files generated:"
    ls -la "$OUTPUT_DIR" | grep -E "\.(pdf|html)$" | while read -r line; do
        echo "  $line"
    done

    if [[ "$has_latex" == "false" ]]; then
        log_info ""
        log_warn "Note: PDF generation not available. Install LaTeX for PDF support:"
        log_info "  brew install --cask mactex"
    fi
}

# Script arguments handling
case "${1:-export}" in
    "export"|"")
        main
        ;;
    "clean")
        log_info "Cleaning export directory..."
        rm -rf "$OUTPUT_DIR"
        log_success "Export directory cleaned"
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  export (default)  Export all documentation to PDF/HTML"
        echo "  clean            Remove all generated files"
        echo "  help             Show this help message"
        echo ""
        echo "Requirements:"
        echo "  pandoc           Document conversion (auto-installed via brew)"
        echo "  pdflatex         PDF generation (optional, via mactex)"
        echo ""
        echo "Output:"
        echo "  $OUTPUT_DIR"
        ;;
    *)
        log_error "Unknown command: $1"
        log_info "Use '$0 help' for usage information"
        exit 1
        ;;
esac