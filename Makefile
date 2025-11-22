# Makefile for VRChat Tutorial Document
# Using uplatex + dvipdfmx compilation chain

# Build output directory
BUILD_DIR = build

# Variables for template
TEMPLATE_SOURCE = templates/template_B5.tex
TEMPLATE_BASE = template_B5
TEMPLATE_DVI = $(BUILD_DIR)/$(TEMPLATE_BASE).dvi
TEMPLATE_PDF = $(BUILD_DIR)/$(TEMPLATE_BASE).pdf
TEMPLATE_PDF_NOTRIM = $(BUILD_DIR)/$(TEMPLATE_BASE)-notrim.pdf

# Variables for airi-youtube-live document
AIRI_SOURCE = latex/airi-youtube-live.tex
AIRI_BASE = airi-youtube-live
AIRI_DVI = $(BUILD_DIR)/$(AIRI_BASE).dvi
AIRI_PDF = $(BUILD_DIR)/$(AIRI_BASE).pdf
AIRI_PDF_NOTRIM = $(BUILD_DIR)/$(AIRI_BASE)-notrim.pdf

# Default target (build airi document)
all: airi

# ========== AIRI Document Targets ==========

# Build both versions of AIRI document (with and without trim marks)
airi: airi-trim airi-notrim

# PDF generation from DVI (with trim marks) for AIRI
airi-trim: $(AIRI_PDF)

$(AIRI_PDF): $(AIRI_DVI)
	cd latex && dvipdfmx -o ../$(AIRI_PDF) ../$(AIRI_DVI)

# DVI generation from TEX for AIRI
$(AIRI_DVI): $(AIRI_SOURCE) | $(BUILD_DIR)
	cd latex && uplatex -output-directory=../$(BUILD_DIR) $(AIRI_BASE).tex
	cd latex && uplatex -output-directory=../$(BUILD_DIR) $(AIRI_BASE).tex

# PDF without trim marks for AIRI
airi-notrim: $(AIRI_PDF_NOTRIM)

$(AIRI_PDF_NOTRIM): $(AIRI_SOURCE) | $(BUILD_DIR)
	cd latex && uplatex -output-directory=../$(BUILD_DIR) -jobname=$(AIRI_BASE)-notrim '\def\notrimmarks{}\input{$(AIRI_BASE)}'
	cd latex && uplatex -output-directory=../$(BUILD_DIR) -jobname=$(AIRI_BASE)-notrim '\def\notrimmarks{}\input{$(AIRI_BASE)}'
	cd latex && dvipdfmx -o ../$(AIRI_PDF_NOTRIM) ../$(BUILD_DIR)/$(AIRI_BASE)-notrim.dvi

# ========== Template Document Targets ==========

# Build both versions of template (with and without trim marks)
template: template-trim template-notrim

# PDF generation from DVI (with trim marks) for template
template-trim: $(TEMPLATE_PDF)

$(TEMPLATE_PDF): $(TEMPLATE_DVI)
	dvipdfmx -o $(TEMPLATE_PDF) $(TEMPLATE_DVI)

# DVI generation from TEX for template
$(TEMPLATE_DVI): $(TEMPLATE_SOURCE) | $(BUILD_DIR)
	cd templates && uplatex -output-directory=../$(BUILD_DIR) $(TEMPLATE_BASE).tex
	cd templates && uplatex -output-directory=../$(BUILD_DIR) $(TEMPLATE_BASE).tex

# PDF without trim marks for template
template-notrim: $(TEMPLATE_PDF_NOTRIM)

$(TEMPLATE_PDF_NOTRIM): $(TEMPLATE_SOURCE) | $(BUILD_DIR)
	cd templates && uplatex -output-directory=../$(BUILD_DIR) -jobname=$(TEMPLATE_BASE)-notrim '\def\notrimmarks{}\input{$(TEMPLATE_BASE)}'
	cd templates && uplatex -output-directory=../$(BUILD_DIR) -jobname=$(TEMPLATE_BASE)-notrim '\def\notrimmarks{}\input{$(TEMPLATE_BASE)}'
	dvipdfmx -o $(TEMPLATE_PDF_NOTRIM) $(BUILD_DIR)/$(TEMPLATE_BASE)-notrim.dvi

# ========== Utility Targets ==========

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean auxiliary files
clean:
	rm -f $(BUILD_DIR)/*.aux $(BUILD_DIR)/*.log $(BUILD_DIR)/*.out $(BUILD_DIR)/*.toc

# Clean all generated files including PDF and DVI
distclean: clean
	rm -f $(BUILD_DIR)/*.dvi $(BUILD_DIR)/*.pdf

# Force rebuild
rebuild: distclean all

# Show help
help:
	@echo "Available targets:"
	@echo "  all (default)              - Build AIRI document (with and without trim marks)"
	@echo "  airi                       - Build AIRI document (with and without trim marks)"
	@echo "  airi-trim                  - Build AIRI PDF with trim marks"
	@echo "  airi-notrim                - Build AIRI PDF without trim marks"
	@echo "  template                   - Build template document (with and without trim marks)"
	@echo "  template-trim              - Build template PDF with trim marks"
	@echo "  template-notrim            - Build template PDF without trim marks"
	@echo "  clean                      - Remove auxiliary files"
	@echo "  distclean                  - Remove all generated files"
	@echo "  rebuild                    - Clean and rebuild everything"
	@echo "  help                       - Show this help"

.PHONY: all airi airi-trim airi-notrim template template-trim template-notrim clean distclean rebuild help
