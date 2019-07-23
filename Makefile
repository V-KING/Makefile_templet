# Edit by liubaolong@20190110

TARGET := a.out

CROSS_COMPILE ?= /home/hhh/petalinux_tool/opt/pkg/petalinux/2018.3/tools/linux-i386/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-

CC := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++
 
#注意每行后面不要有空格，否则会算到目录名里面，导致问题
SRC_DIR = .
BUILD_DIR = tmp
OBJ_DIR = $(BUILD_DIR)/obj
DEPS_DIR  = $(BUILD_DIR)/deps
 
#这里添加其他头文件路径
INC_DIR = \
	-I./ \
	-I./include \
	-I/home/hhh/extdisk1/htpr/build/tmp/work/plnx_zynq7-xilinx-linux-gnueabi/linux-xlnx/4.14-xilinx-v2018.3+gitAUTOINC+eeab73d120-r0/recipe-sysroot/usr/include/ \
	
#这里添加编译参数
CC_FLAGS := $(INC_DIR) -g -std=gnu9x
CXX_FLAGS := $(INC_DIR) -g -std=c++11
LNK_FLAGS := \
	-L/usr/local/lib
 
#这里递归遍历3级子目录
DIRS := $(shell find $(SRC_DIR) -maxdepth 3 -type d)
 
#将每个子目录添加到搜索路径
VPATH = $(DIRS)
 
#查找src_dir下面包含子目录的所有cpp文件
SOURCES	= $(foreach dir, $(DIRS), $(wildcard $(dir)/*.c $(dir)/*.cpp))  
OBJS   	= $(addprefix $(OBJ_DIR)/,$(patsubst %.c,%.o, $(patsubst %.cpp,%.o, $(notdir $(SOURCES)))))  
all:$(TARGET)
$(TARGET):$(OBJS)
	@$(NQ) "Generating executable file..." $(notdir $(target))
	@$(CXX) $^ $(LNK_FLAGS) -o $@

#编译之前要创建OBJ目录，确保目录存在
Q=@
NQ=echo
$(OBJ_DIR)/%.o:%.c
	$(Q)if [ ! -d $(OBJ_DIR) ]; then mkdir -p $(OBJ_DIR); fi;
	@$(NQ) "Compiling: " $(addsuffix .cpp, $(basename $(notdir $@)))
	$(Q)$(CC) -c $(CC_FLAGS) -o $@ $<
$(OBJ_DIR)/%.o:%.cpp
	$(Q)if [ ! -d $(OBJ_DIR) ]; then mkdir -p $(OBJ_DIR); fi;
	@$(NQ) "Compiling: " $(addsuffix .cpp, $(basename $(notdir $@)))
	$(Q)$(CXX) -c $(CXX_FLAGS) -o $@ $<

test:
	echo $@.$$$$
valgrind:
	valgrind --log-file=./valgrind.log --tool=memcheck --leak-check=full --show-reachable=yes  --track-origins=yes ./$(target)
style:
	find ./ -name "*.h" -or -name "*.c" -or -name "*.cpp"|egrep -v 'xxx' \
	| xargs astyle -p --suffix=none --style=java
release: 
	make clean
	@make all ver=release
	make move
dist:
	if [ ! -d dist ]; then mkdir -p $(BUILD_DIR)/dist; fi; \
	cp `ls | egrep -v $(BUILD_DIR)` $(BUILD_DIR)/dist -a; \
	tar -zcf $(BUILD_DIR)/dist.tar.gz $(BUILD_DIR)/dist; rm -rf $(BUILD_DIR)/dist
distclean:
	make clean;rm -rf dist dist.tar.gz
#前面加-表示忽略错误
.PHONY : clean
clean:
	rm -rf $(BUILD_DIR) $(TARGET)
