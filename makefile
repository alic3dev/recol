name=recol

directory_air=air
directory_include=include
directory_metal=metal
directory_metalar=metalar
directory_objects_c=objects_c
directory_objects_obj_c=objects_obj_c
directory_output=output/${name}.app
directory_sources=sources

directory_cer0=../cer0
directory_cer0_include=${directory_cer0}/include
directory_cer0_library=${directory_cer0}/library/ios/release

directory_clic3=../clic3
directory_clic3_include=${directory_clic3}/include
directory_clic3_library=${directory_clic3}/library/ios/release

directory_interrupt_handler=../interrupt_handler
directory_interrupt_handler_library=${directory_interrupt_handler}/library/ios/release

directory_math_c=../math_c
directory_math_c_include=${directory_math_c}/include
directory_math_c_library=${directory_math_c}/library/ios/release
directory_math_c_metalar=${directory_math_c}/metalar/ios

directory_metil=../metil
directory_metil_include=${directory_metil}/include
directory_metil_library=${directory_metil}/library/ios/release
directory_metil_storyboards=${directory_metil}/storyboards

files_sources=${shell find ${directory_sources} -name "*.[cm]"}
files_objects_c=${patsubst ${directory_sources}/%.c,${directory_objects_c}/%.o,${filter-out %.m,${files_sources}}}
files_objects_obj_c=${patsubst ${directory_sources}/%.m,${directory_objects_obj_c}/%.o,${filter-out %.c,${files_sources}}}
files_objects=${files_objects_c} ${files_objects_obj_c}

file_output=${directory_output}/${name}

file_metalar=${directory_metalar}/${name}.metalar

file_info_plist=Info.plist
file_output_info_plist=${directory_output}/Info.plist

file_metil_storyboard=${directory_metil_storyboards}/metil_ios.storyboard

file_math_c_metalar=${directory_math_c_metalar}/math_c_sine.metalar
files_metil_metalars=${directory_metil_library}/metil_metal_colours.metalar ${directory_metil_library}/metil_metal_model.metalar

file_cer0_library=${directory_cer0_library}/cer0_ios.o
file_clic3_library=${directory_clic3_library}/clic3_ios.o
file_interrupt_handler_library=${directory_interrupt_handler_library}/interrupt_handler_ios.o
file_math_c_library=${directory_math_c_library}/math_c_ios.o
file_metil_library=${directory_metil_library}/metil.o

files_libraries=${file_cer0_library} ${file_clic3_library} ${file_interrupt_handler_library} ${file_math_c_library} ${file_metil_library}

file_entitlements=${directory_sources}/${name}.app.xcent

files_metal=${wildcard ${directory_metal}/*.metal}
files_air=${patsubst ${directory_metal}/%.metal,${directory_air}/%.air,${files_metal}}
file_output_metal=${directory_output}/default.metallib

files_storyboards=${file_metil_storyboard}
files_storyboards_compiled=${patsubst ${directory_metil_storyboards}/%.storyboard,${directory_output}/%.storyboardc,${files_storyboards}}

sdk_path=${shell xcrun -sdk iphoneos --show-sdk-path}

cc=clang

frameworks=MetalKit AVFAudio UIKit

target_device=iphone
ifndef target_device_version
target_device_version=26.1
endif

ifndef target_metal_standard
target_metal_standard=metal4.0
endif

ifndef target_metal_version
target_metal_version=${target_device_version}
endif

target_platform=arm64-apple-ios${target_device_version}
target_platform_metal=air64-apple-ios${target_metal_version}

cc=clang
c_flags_includes=-I${directory_include} -I${directory_cer0_include} -I${directory_clic3_include} -I${directory_math_c_include} -I${directory_metil_include}
c_flags_platform=-target ${target_platform} -isysroot ${sdk_path}

c_flags_c=${c_flags_platform} -O3 ${c_flags_includes} -Dtarget_os_ios
c_flags_obj_c=${c_flags_platform} -O3 ${c_flags_includes} -x objective-c -fmodules -fconstant-cfstrings -Dtarget_os_ios
c_flags_frameworks=${addprefix -framework ,${frameworks}}

metal=xcrun -sdk macosx metal
metal_ar=xcrun -sdk macosx metal-ar
metallib=xcrun -sdk macosx metallib
metal_flags_common=-target ${target_platform_metal} -std=${target_metal_standard}
metal_flags=${metal_flags_common} ${c_flags_includes} -isysroot ${sdk_path}

ifneq (${disable_metal_fast_options}, 1)
	metal_flags:=${metal_flags} -fmetal-math-mode\=fast -fmetal-math-fp32-functions\=fast
endif

metal_flags_output=

all: ${file_output} ${file_output_metal} ${files_storyboards_compiled} ${file_output_info_plist}

${name}: all

${file_output}: ${files_objects}
	mkdir -p ${directory_output}
	${cc} ${c_flags_platform} ${c_flags_frameworks} ${files_objects} ${files_libraries} -o ${file_output}

${directory_objects_c}/%.o: ${directory_sources}/%.c
	mkdir -p ${dir $@}
	${cc} ${c_flags_c} -c $< -o $@

${directory_objects_obj_c}/%.o: ${directory_sources}/%.m
	mkdir -p ${dir $@}
	${cc} ${c_flags_obj_c} -c $< -o $@

${file_output_metal}: ${file_metalar}
	mkdir -p ${dir $@}
	${metallib} ${metal_flags_output} ${file_metalar} ${files_metil_metalars} ${file_math_c_metalar} -o ${file_output_metal}

${file_metalar}: ${files_air}
	mkdir -p ${directory_metalar}
	if [[ -f ${file_metalar} ]]; then rm ${file_metalar}; fi
	${metal_ar} -rc ${file_metalar} ${files_air}

${directory_air}/%.air: ${directory_metal}/%.metal
	mkdir -p ${dir $@}
	${metal} ${metal_flags} -c $< -o $@

${directory_output}/%.storyboardc: ${directory_metil_storyboards}/%.storyboard
	mkdir -p ${directory_output}
	ibtool --module ${name} --target-device ${target_device} --minimum-deployment-target ${target_device_version} --output-format human-readable-text $< --compilation-directory ${directory_output}

${file_output_info_plist}: ${file_info_plist}
	mkdir -p ${directory_output}
	cp ${file_info_plist} ${file_output_info_plist}

ifndef codesigning_id
codesigning_id=${shell security find-identity -v -p codesigning | grep "1)" | tr -s ' ' | cut -d ' ' -f 3}
endif

ifndef device_identifier
device_identifier=${shell devicectl list devices --filter "model beginswith 'iphone'" --filter "state == 'connected' || state beginswith 'available'" --hide-headers | head -n 1 | tr -s ' ' | grep -v "No devices found." | cut -d ' ' -f 3}
endif

bundle_identifier=dev.alic3.${name}
ifndef provisioning_profile_identifier
provisioning_profile_identifier=
endif
application_identifier=${provisioning_profile_identifier}.${bundle_identifier}

message_error_no_codesigning_id_found=no_codesigning_id_found
message_error_no_devices_found=no_devices_found

sign: .always
ifeq (${codesigning_id},)
	printf "${message_error_no_codesigning_id_found}\n" >&2
	exit 1
else
	printf "<plist>\n\n  <dict>\n    <key>application-identifier</key>\n    <string>${application_identifier}</string>\n  </dict>\n</plist>\n" > ${file_entitlements}
	codesign --force --sign ${codesigning_id} --entitlements ${file_entitlements} ${directory_output}
	rm ${file_entitlements}
endif

install: .always
ifeq (${device_identifier},)
	printf "${message_error_no_devices_found}\n" >&2
	exit 2
else
	devicectl device install app --device ${device_identifier} ${directory_output}
endif

run: .always
ifeq (${device_identifier},)
	printf "${message_error_no_devices_found}\n" >&2
	exit 2
else
	devicectl device process launch -d ${device_identifier} --console ${bundle_identifier}
endif

clean: clean_air clean_metalar clean_output clean_objects

clean_air:
	-rm -r ${directory_air}

clean_metalar:
	-rm -r ${directory_metalar}

clean_objects: clean_objects_c clean_objects_obj_c

clean_objects_c:
	-rm -r ${directory_objects_c}

clean_objects_obj_c:
	-rm -r ${directory_objects_obj_c}

clean_output:
	-rm -r ${directory_output}

.always:
