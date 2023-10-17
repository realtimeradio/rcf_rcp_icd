#! /bin/bash
pdfname=D2k-00017-RCF-ICD-RCF_RCP_interface.pdf

pandoc docs/*.md -o ${pdfname} -s -V colorlinks -V links-as-notes --number-sections --template template-pd2.9.latex 
