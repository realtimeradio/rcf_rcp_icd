---
title: RCF-RCP Interface Specification
author:
- Jack Hickish\textsuperscript{1}
affiliation:
- \textsuperscript{1} Real-Time Radio Systems Ltd
abstract:
document-number: 00019
wbs-level-2: Radio Camera Frontend
wbs-level-2-abbrev: RCF
document-type: Interface Control Document
document-type-abbrev: ICD
revisions:
- version: 1
  date: 2023-08-01
  sections: all
  remarks: Original
  authors: JH
- version: 2
  date: 2023-08-14
  sections: 4. Interface Definition
  remarks: Change `N_CHAN` requirement to be a multiple of 4 (was 8). Clarify that `N_TIME` is the total number of times in a packet including the ``fine time'' axis.
  authors: JH
- version: 3
  date: 2023-10-17
  sections: all
  remarks: Re-title to use DSA document numbering. Port to DSA document template.
  authors: JH
- version: 4
  date: 2023-10-19
  sections: Title
  remarks: Title change
  authors: JH
...
