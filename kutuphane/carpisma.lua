local M = {}
function M.nokta_dortgene_dahil_mi(nokta_vek2, dortgen_yer_vek2, dortgen_boyut_vek2)
    return nokta_vek2.x > dortgen_yer_vek2.x and 
           nokta_vek2.x < dortgen_yer_vek2.x + dortgen_boyut_vek2.x and
           nokta_vek2.y > dortgen_yer_vek2.y and
           nokta_vek2.y < dortgen_yer_vek2.y + dortgen_boyut_vek2.y
end

return M