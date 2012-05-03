#<KHeader>
#+=========================================================================
#I  Project Name: Scripts
#+=========================================================================
#I   Copyright: Copyright (c) 2004-2012, John Kearney
#I      Author: John Kearney,                  dethrophes@web.de
#I
#I     License: All rights reserved. This program and the accompanying 
#I              materials are licensed and made available under the 
#I              terms and conditions of the BSD License which 
#I              accompanies this distribution. The full text of the 
#I              license may be found at 
#I              http://opensource.org/licenses/bsd-license.php
#I              
#I              THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN '
#I              AS IS' BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
#I              ANY KIND, EITHER EXPRESS OR IMPLIED.
#I
#I Description: Auto Created for Makefile
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : Makefile
#I  File Location        : Experimental-Bash-Module-System/bash/docs/
#I                         vtparse
#I
#+=========================================================================
#</KHeader>

RUBY_GENERATION_FILES = vtparse_gen_c_tables.rb vtparse_tables.rb

all: vtparse_table.c vtparse_table.h test

clean:
	rm -f vtparse_table.c vtparse_table.h test

vtparse_table.c: $(RUBY_GENERATION_FILES)
	ruby vtparse_gen_c_tables.rb

vtparse_table.h: $(RUBY_GENERATION_FILES)
	ruby vtparse_gen_c_tables.rb

test: vtparse.c vtparse.h vtparse_table.c vtparse_table.h vtparse_test.c
	gcc -o test vtparse_test.c vtparse.c vtparse_table.c

.PHONY: all clean

