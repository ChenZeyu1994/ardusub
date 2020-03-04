# find the mk/ directory, which is where this makefile fragment
# lives. (patsubst strips the trailing slash.)
SYSTYPE			:=	$(shell uname)

ifneq ($(findstring CYGWIN, $(SYSTYPE)),) 
  MK_DIR := $(shell cygpath -m ../mk)
else
  MK_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
endif
#设置环境变量
include $(MK_DIR)/environ.mk

# short-circuit build for the configure target
#用来响应make configure指令
ifeq ($(MAKECMDGOALS),configure)
include $(MK_DIR)/configure.mk

else
#用来响应 make help指令,显示帮助信息.
# short-circuit build for the help target
include $(MK_DIR)/help.mk

# common makefile components
#用来执行目标程序的编译动作,脚本会依据BOARDS和FRAMES
#变量定义的关键字来在make的命令行里查找目标,然后编译它;
#该文件用来动态生成一个编译依赖关系,通过eval函数;
#同时,clean 的动作在此定义;脚本会包含 modules.mk
#和mavgen.mk还有uavcangen.mk三个文件;
include $(MK_DIR)/targets.mk

#加载所有类型项目的源文件到指定变量,并设置其目标obj文件,
#这两个变量为 SKETCHSRCS 和 SKETCHOBJS;
#并加载make.inc文件中的列表目录到变量 LIBTOKENS 中,然后
#再去添加具体平台相关的库目录;脚本设置如下一些变量:
#SKETCHLIBS -------所有库文件路径列表(绝对路径);
#SKETCHLIBNAMES ---所有库文件路径列表(相对路径);
#SKETCHLIBSRCDIRS--为SKETCHLIBS列表中每一项添加/utility#
#子路径,因为有些库目录下面还有utility子目录;
#SKETCHLIBSRCS-----所有库源文件绝对路径;
#SKETCHLIBOBJS-----SKETCHLIBSRCS对应的.o文件,路径在Build目录下面;
#SKETCHLIBINCLUDES----所有依据路径(libraries),和GCS_MAVLink路径;
#SKETCHLIBSRCSRELATIVE--SKETCHLIBSRCS的相对路径;
include $(MK_DIR)/sketch_sources.mk

#板载总线协议
include $(SKETCHBOOK)/modules/uavcan/libuavcan/include.mk

ifneq ($(MAKECMDGOALS),clean)

# board specific includes
ifeq ($(HAL_BOARD),HAL_BOARD_SITL)
include $(MK_DIR)/board_native.mk
endif

ifeq ($(HAL_BOARD),HAL_BOARD_LINUX)
include $(MK_DIR)/board_linux.mk
endif

ifeq ($(HAL_BOARD),HAL_BOARD_PX4)
include $(MK_DIR)/board_px4.mk
endif

ifeq ($(HAL_BOARD),HAL_BOARD_VRBRAIN)
include $(MK_DIR)/board_vrbrain.mk
endif

ifeq ($(HAL_BOARD),HAL_BOARD_QURT)
include $(MK_DIR)/board_qurt.mk
endif

endif

endif
