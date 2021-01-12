# COMPILER
CC = g++-7
AR = ar

# TARGET NAMES
TARGET = vasim
LIBVASIM = libvasim.a

# DIRECTORIES
IDIR = ./include
SRCDIR = ./src
MNRL = ./libs/MNRL/C++
PUGI = ./libs/pugixml

# LIBRARY DEPENDENCIES
LIBMNRL = $(MNRL)/libmnrl.a
LIBPUGI = $(PUGI)/build/make-$(CC)-release-standard-c++11/src/pugixml.cpp.o

# FLAGS
CXXFLAGS= -I$(IDIR) -I$(MNRL)/include -I$(PUGI)/src -pthread --std=c++17 -Wno-deprecated
OPTS = -Ofast
ARFLAGS = rcs

CXXFLAGS += $(OPTS)

_DEPS = *.h
_OBJ = errors.o util.o ste.o ANMLParser.o MNRLAdapter.o automata.o element.o specialElement.o gate.o and.o or.o nor.o counter.o inverter.o 

MAIN_CPP = main.cpp

ODIR=$(SRCDIR)/obj

DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

#
all: submodule_init vasim_release

vasim_release: mnrl pugi
	$(info  )
	$(info Compiling VASim Library...)
	$(MAKE) $(TARGET)

mnrl:	
	$(info  )
	$(info Compiling MNRL Library...)
	$(MAKE) $(LIBMNRL)

pugi:	
	$(info )
	$(info Compiling PugiXML Library...)
	$(MAKE) $(LIBPUGI) 

$(TARGET): $(SRCDIR)/$(MAIN_CPP) $(LIBVASIM) $(LIBMNRL)
	$(info  )
	$(info Compiling VASim executable...)
	$(CC) $(CXXFLAGS) $^ -o $@  

$(LIBVASIM): $(LIBPUGI) $(OBJ)
	$(AR) $(ARFLAGS) $@ $^ 


$(ODIR)/%.o: $(SRCDIR)/%.cpp $(DEPS) $(LIBMNRL)
	@mkdir -p $(ODIR)	
	$(CC) $(CXXFLAGS) -c -o $@ $< 

$(LIBMNRL):
	$(MAKE) CC=$(CC) -C $(MNRL)

$(LIBPUGI):
	$(MAKE) CXX=$(CC) -Wno-deprecated config=release -C $(PUGI)

clean: cleanvasim cleanmnrl cleanpugi

cleanvasim:
	$(info Cleaning VASim...)
	rm -f $(ODIR)/*.o $(TARGET) $(SNAME)

cleanmnrl:
	$(info Cleaning MNRL...)
	rm -f $(MNRL)/libmnrl.a $(MNRL)/libmnrl.so $(MNRL)/src/obj/*.o

cleanpugi:
	$(info Cleaning PugiXML...)
	rm -rf $(PUGI)/build

submodule_init:
	@git submodule update --init --recursive

.PHONY: clean cleanvasim cleanmnrl cleanpugi vasim_release mnrl pugi submodule_init
