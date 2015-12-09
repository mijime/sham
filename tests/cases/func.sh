__dplg_v_debug=1
__dplg_v_verbose=1

test -d "${DEPLUG_HOME}" && \rm -r "${DEPLUG_HOME}"
mkdir -p ${DEPLUG_HOME}/dir "${DEPLUG_HOME}/space dir" "${DEPLUG_BIN}"

echo "echo Include1.sh" > ${DEPLUG_HOME}/dir/include1.sh
echo "echo Include2.sh" > ${DEPLUG_HOME}/dir/include2.sh
echo "echo Include3.sh" > ${DEPLUG_HOME}/dir/include3.sh
echo "echo Include4.sh" > ${DEPLUG_HOME}/dir/include4.sh
echo "echo Include1.sh on space" > "${DEPLUG_HOME}/space dir/include1.sh"
echo "echo Include2.sh on space" > "${DEPLUG_HOME}/space dir/include2.sh"

find ${DEPLUG_HOME}

evalute 'glob'    __dplg_f_glob  "${DEPLUG_HOME}/dir"
evalute 'parse'   __dplg_f_parse "name:#plugin:#dir:${DEPLUG_HOME}/dir#tag:#post:cat *.sh#of:*.sh#use:*.sh"
evalute 'of'      __dplg_f_of
evalute 'use'     __dplg_f_use
evalute 'post'    __dplg_f_post
evalute 'include' __dplg_f_include

evalute 'spacedir glob'    __dplg_f_glob  "${DEPLUG_HOME}/space\ dir"
evalute 'spacedir parse'   __dplg_f_parse "name:#plugin:#dir:${DEPLUG_HOME}/space\ dir#tag:#post:cat *.sh#of:*.sh#use:*.sh"
evalute 'spacedir of'      __dplg_f_of
evalute 'spacedir use'     __dplg_f_use
evalute 'spacedir include' __dplg_f_include
# evalute 'spacedir post'  __dplg_f_post # TODO

find ${DEPLUG_HOME}
