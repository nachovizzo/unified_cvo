#/bin/bash

cd build 
make -j 
cd ..
#./build/bin/cvo_irls_tum /home/rayzhang/media/Samsung_T5/tum/freiburg3_structure_notexture_near cvo_params/cvo_intensity_params_irls_tum.yaml graph_defs/fr3/tum_fr3_structure_notexture_near/10_graph.txt /home/rayzhang/media/Samsung_T5/tum/freiburg3_structure_notexture_near/CVO.txt  
#gdb -ex run --args \
#./build/bin/cvo_irls_tartan /home/rayzhang/media/Samsung_T5/tartanair/abandonedfactory_night/Easy/P001/  cvo_params/cvo_outdoor_params.yaml graph_defs/tartan/tartan_Easy_abandonedfactory_night/200_graph.txt.new 1
#./build/bin/cvo_irls_tartan /home/rayzhang/media/Samsung_T5/tartanair/abandonedfactory/Easy/P001/  cvo_params/cvo_outdoor_params.yaml graph_defs/tartan/tartan_Easy_abandonedfactory/10_graph.txt 1
./build/bin/cvo_irls_tartan /home/rayzhang/media/Samsung_T5/tartanair/endofworld/Easy/P001/  cvo_params/cvo_outdoor_params.yaml /home/rayzhang/dsm/tartan_Easy_endofworld/7_graph.txt 1 /home/rayzhang/dsm/tartan_Easy_endofworld/
#./build/bin/cvo_irls_tartan /home/rayzhang/media/Samsung_T5/tartanair/abandonedfactory_night/Easy/P001/  cvo_params/cvo_outdoor_params.yaml ../dsm/tartan_Easy_abandonedfactory_night/18_graph.txt 1

