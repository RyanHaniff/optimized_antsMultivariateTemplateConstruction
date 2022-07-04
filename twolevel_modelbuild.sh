#!/bin/bash

# Created by argbash-init v2.10.0
# ARG_HELP([A wrapper to enable two-level modelbuild (aka longitudinal) modelling using optimized_antsMultivariateTemplateConstruction])
# ARG_OPTIONAL_SINGLE([output-dir],[],[Output directory for modelbuild],[output])
# ARG_OPTIONAL_SINGLE([masks],[],[File containing mask filenames, identical to inputs in structure],[])
# ARG_OPTIONAL_BOOLEAN([debug],[],[Debug mode, print all commands to stdout],[])
# ARG_POSITIONAL_SINGLE([inputs],[Input text files, one line per subject, comma separated scans per subject],[])
# ARG_OPTIONAL_BOOLEAN([dry-run],[],[Dry run, don't run any commands, implies debug],[])
# ARG_LEFTOVERS([Arguments to be passed to modelbuild.sh without validation])
# ARGBASH_SET_INDENT([  ])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.10.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
  local _ret="${2:-1}"
  test "${_PRINT_HELP:-no}" = yes && print_help >&2
  echo "$1" >&2
  exit "${_ret}"
}


begins_with_short_option()
{
  local first_option all_short_options='h'
  first_option="${1:0:1}"
  test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
_arg_leftovers=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_output_dir="output"
_arg_masks=
_arg_debug="off"
_arg_dry_run="off"


print_help()
{
  printf '%s\n' "A wrapper to enable two-level modelbuild (aka longitudinal) modelling using optimized_antsMultivariateTemplateConstruction"
  printf 'Usage: %s [-h|--help] [--output-dir <arg>] [--masks <arg>] [--(no-)debug] [--(no-)dry-run] <inputs> ... \n' "$0"
  printf '\t%s\n' "<inputs>: Input text files, one line per subject, comma separated scans per subject"
  printf '\t%s\n' "... : Arguments to be passed to modelbuild.sh without validation"
  printf '\t%s\n' "-h, --help: Prints help"
  printf '\t%s\n' "--output-dir: Output directory for modelbuild (default: 'output')"
  printf '\t%s\n' "--masks: File containing mask filenames, identical to inputs in structure (no default)"
  printf '\t%s\n' "--debug, --no-debug: Debug mode, print all commands to stdout (off by default)"
  printf '\t%s\n' "--dry-run, --no-dry-run: Dry run, don't run any commands, implies debug (off by default)"
}


parse_commandline()
{
  _positionals_count=0
  while test $# -gt 0
  do
    _key="$1"
    case "$_key" in
      -h|--help)
        print_help
        exit 0
        ;;
      -h*)
        print_help
        exit 0
        ;;
      --output-dir)
        test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
        _arg_output_dir="$2"
        shift
        ;;
      --output-dir=*)
        _arg_output_dir="${_key##--output-dir=}"
        ;;
      --masks)
        test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
        _arg_masks="$2"
        shift
        ;;
      --masks=*)
        _arg_masks="${_key##--masks=}"
        ;;
      --no-debug|--debug)
        _arg_debug="on"
        test "${1:0:5}" = "--no-" && _arg_debug="off"
        ;;
      --no-dry-run|--dry-run)
        _arg_dry_run="on"
        test "${1:0:5}" = "--no-" && _arg_dry_run="off"
        ;;
      *)
        _last_positional="$1"
        _positionals+=("$_last_positional")
        _positionals_count=$((_positionals_count + 1))
        ;;
    esac
    shift
  done
}


handle_passed_args_count()
{
  local _required_args_string="'inputs'"
  test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require at least 1 (namely: $_required_args_string), but got only ${_positionals_count}." 1
}


assign_positional_args()
{
  local _positional_name _shift_for=$1
  _positional_names="_arg_inputs "
  _our_args=$((${#_positionals[@]} - 1))
  for ((ii = 0; ii < _our_args; ii++))
  do
    _positional_names="$_positional_names _arg_leftovers[$((ii + 0))]"
  done

  shift "$_shift_for"
  for _positional_name in ${_positional_names}
  do
    test $# -gt 0 || break
    eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
    shift
  done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

set -euo pipefail

# shellcheck source=helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

# Setup a timestamp for prefixing all commands
_datetime=$(date -u +%F_%H-%M-%S-UTC)

# Setup a directory which contains all commands run
# for this invocation
mkdir -p ${_arg_output_dir}/jobs/${_datetime}

# Store the full command line for each run
echo ${__invocation} >${_arg_output_dir}/jobs/${_datetime}/invocation

mkdir -p ${_arg_output_dir}/secondlevel/inputs
rm -f ${_arg_output_dir}/secondlevel/input_files.txt

info "Launching modelbuilds for each input row"

i=1
while read -r subject_scans; do
  IFS=',' read -r -a scans <<<${subject_scans}
  mkdir -p ${_arg_output_dir}/firstlevel/subject_${i}
  ln -sfr ${_arg_output_dir}/firstlevel/subject_${i}/final/average/template_sharpen_shapeupdate.nii.gz ${_arg_output_dir}/secondlevel/inputs/subject_${i}.nii.gz
  printf "%s\n" ${_arg_output_dir}/secondlevel/inputs/subject_${i}.nii.gz >> ${_arg_output_dir}/secondlevel/input_files.txt
  printf "%s\n" "${scans[@]}" > ${_arg_output_dir}/firstlevel/subject_${i}/input_files.txt

  if [[ ${#scans[@]} -gt 1 ]]; then
    debug "${__dir}/modelbuild.sh --jobname-prefix "twolevel_${_datetime}_subject_${i}_" ${_arg_leftovers[@]} --output-dir ${_arg_output_dir}/firstlevel/subject_${i} ${_arg_output_dir}/firstlevel/subject_${i}/input_files.txt"
    ${__dir}/modelbuild.sh \
      --jobname-prefix "twolevel_${_datetime}_subject_${i}_" \
      ${_arg_leftovers[@]} \
      --output-dir ${_arg_output_dir}/firstlevel/subject_${i} \
      ${_arg_output_dir}/firstlevel/subject_${i}/input_files.txt
  else
    # Generate Idenity Transforms
    info "Subject ${i} has only a single scan and will not have a subject wise average, it will be included in the second level model build"
    mkdir -p ${_arg_output_dir}/firstlevel/subject_${i}/final/{transforms,resample,average}
    ln -sfr $(realpath ${scans[0]}) ${_arg_output_dir}/firstlevel/subject_${i}/final/average/template_sharpen_shapeupdate.nii.gz
    ImageMath 3 ${_arg_output_dir}/firstlevel/subject_${i}/final/transforms/$(basename ${scans[0]} | extension_strip)_0GenericAffine.mat MakeAffineTransform 1
    CreateImage 3 ${scans[0]} ${_arg_output_dir}/firstlevel/subject_${i}/final/transforms/$(basename ${scans[0]} | extension_strip)_1Warp.nii.gz 0
    CreateDisplacementField 3 0 \
      ${_arg_output_dir}/firstlevel/subject_${i}/final/transforms/$(basename ${scans[0]} | extension_strip)_1Warp.nii.gz \
      ${_arg_output_dir}/firstlevel/subject_${i}/final/transforms/$(basename ${scans[0]} | extension_strip)_1Warp.nii.gz \
      ${_arg_output_dir}/firstlevel/subject_${i}/final/transforms/$(basename ${scans[0]} | extension_strip)_1Warp.nii.gz \
      ${_arg_output_dir}/firstlevel/subject_${i}/final/transforms/$(basename ${scans[0]} | extension_strip)_1InverseWarp.nii.gz
    cp -f ${_arg_output_dir}/firstlevel/subject_${i}/final/transforms/$(basename ${scans[0]} | extension_strip)_1InverseWarp.nii.gz \
      ${_arg_output_dir}/firstlevel/subject_${i}/final/transforms/$(basename ${scans[0]} | extension_strip)_1Warp.nii.gz
  fi
  ((++i))
done < ${_arg_inputs}

debug "${__dir}/modelbuild.sh --skip-file-checks --job-predepend "twolevel_${_datetime}_" ${_arg_leftovers[@]} --output-dir ${_arg_output_dir}/secondlevel ${_arg_output_dir}/secondlevel/input_files.txt"
${__dir}/modelbuild.sh --skip-file-checks --job-predepend "twolevel_${_datetime}_" ${_arg_leftovers[@]} --output-dir ${_arg_output_dir}/secondlevel ${_arg_output_dir}/secondlevel/input_files.txt

# ] <-- needed because of Argbash
