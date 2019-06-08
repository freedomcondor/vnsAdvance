argosBuildDir="../argos3/build"

source $argosBuildDir/setup_env.sh
#source ../argos3-builderbot/build/setup_env.sh

$argosBuildDir/core/argos3 -c structure.argos
#$argosBuildDir/core/argos3 -c demo.argos
#$argosBuildDir/core/argos3 -c transform.argos

