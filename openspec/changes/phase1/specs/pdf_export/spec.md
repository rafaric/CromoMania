# PDF Export Specification

## Purpose

Define how the application generates, formats, and shares PDF documents containing sticker collection data.

---

## Requirements

### Requirement: Full Collection PDF Export

The system MUST generate a PDF containing all stickers in the album with their current collection status.

#### Scenario: Generate Full PDF

- GIVEN the user has collection data loaded
- WHEN the user selects "Export Full Collection"
- THEN the system MUST generate a PDF with all stickers from all sections

#### Scenario: Full PDF Content

- GIVEN a full collection PDF is generated
- THEN the document MUST include:
  - Header with album name ("My WC 2026 Collection")
  - Generation date
  - Table with columns: # (sticker number), Name, Status
  - All stickers listed in section order
  - Legend explaining status symbols

---

### Requirement: Filtered PDF Export (Missing Only)

The system MUST generate a PDF containing only stickers with status = missing.

#### Scenario: Generate Missing-Only PDF

- GIVEN the user has collection data loaded
- WHEN the user selects "Export Missing Stickers"
- THEN the system MUST generate a PDF containing only stickers where count = 0

#### Scenario: Missing-Only PDF Content

- GIVEN a missing-only PDF is generated
- THEN the document MUST include:
  - Header indicating filtered view ("Missing Stickers Only")
  - Only stickers with status = missing
  - Section information for each sticker
  - Count of missing stickers displayed

---

### Requirement: Filtered PDF Export (Section-Specific)

The system MUST generate a PDF containing only stickers from a selected section.

#### Scenario: Generate Section-Specific PDF

- GIVEN the user is viewing a specific section
- WHEN the user selects "Export Section"
- THEN the system MUST generate a PDF containing only stickers from that section

#### Scenario: Section PDF Header

- GIVEN a section-specific PDF is generated
- THEN the header MUST include the section name (e.g., "Group A - Missing Stickers")

---

### Requirement: PDF Status Symbols

The system MUST display status using recognizable symbols that render reliably across PDF viewers.

#### Scenario: Owned Sticker Symbol

- GIVEN a sticker with status = owned
- WHEN the PDF is generated
- THEN the status column MUST display: [✓] or [x] (ASCII checkmark)

#### Scenario: Repeated Sticker Symbol

- GIVEN a sticker with status = repeated
- WHEN the PDF is generated
- THEN the status column MUST display: [2+] indicating count greater than 1

#### Scenario: Missing Sticker Symbol

- GIVEN a sticker with status = missing
- WHEN the PDF is generated
- THEN the status column MUST display: [ ] (empty box)

#### Scenario: Symbol Fallback

- GIVEN emoji rendering may fail on some PDF viewers
- WHEN generating any PDF
- THEN the system MUST use ASCII symbols ([✓], [ ], [2+]) instead of emoji characters

---

### Requirement: PDF Page Formatting

The system MUST format PDFs for standard A4 paper size.

#### Scenario: A4 Page Format

- GIVEN a PDF is generated
- THEN the page format MUST be PdfPageFormat.a4 with appropriate margins (32pt)

#### Scenario: Multi-Page Document

- GIVEN the collection has more stickers than fit on one page
- WHEN the PDF is generated
- THEN the system MUST automatically create additional pages as needed (MultiPage widget)

#### Scenario: Table Column Width

- GIVEN a PDF table is generated
- THEN the columns MUST be sized appropriately:
  - # column: narrow (content fits number)
  - Name column: wide (content fits player/team name)
  - Status column: medium (symbol fits)

---

### Requirement: PDF Sharing

The system MUST allow users to share generated PDFs via native share functionality.

#### Scenario: Share Full Collection PDF

- GIVEN a full collection PDF has been generated
- WHEN the user taps the share button
- THEN the system MUST open the native share sheet with the PDF file attached

#### Scenario: Share Filtered PDF

- GIVEN a filtered PDF (missing-only or section) has been generated
- WHEN the user taps the share button
- THEN the system MUST open the native share sheet with the filtered PDF file attached

#### Scenario: PDF Filename

- GIVEN a PDF is generated for sharing
- THEN the filename SHOULD reflect the content:
  - Full collection: "wc2026_full_collection.pdf"
  - Missing only: "wc2026_missing_only.pdf"
  - Section: "wc2026_group_a.pdf"

#### Scenario: Share Text

- GIVEN a PDF is shared
- THEN the share text SHOULD include: "My WC 2026 sticker list"

---

### Requirement: PDF Generation Error Handling

The system MUST handle PDF generation errors gracefully.

#### Scenario: Generation Failure

- GIVEN PDF generation encounters an error
- WHEN the operation completes with failure
- THEN the system MUST display a user-friendly error message

---

### Requirement: PDF Generation Progress

The system MUST indicate PDF generation is in progress.

#### Scenario: Show Loading Indicator

- GIVEN the user initiates PDF export
- WHEN generation begins
- THEN the system MUST display a loading indicator or progress message

#### Scenario: Hide Indicator on Completion

- GIVEN a loading indicator is displayed
- WHEN PDF generation completes
- THEN the system MUST hide the loading indicator and show the share option

---

## Non-Functional Requirements

### NFR-1: PDF Generation Performance

The system MUST generate a full 670-sticker PDF within 5 seconds on modern Android devices.

### NFR-2: Offline PDF Generation

The system MUST generate PDFs without network connectivity (pure Dart implementation).

### NFR-3: PDF File Size

The system SHOULD generate PDFs with reasonable file size (under 1MB for typical collections).

### NFR-4: Share Package Compatibility

The system MUST use share_plus package for native sharing, ensuring compatibility across Android versions.