import math
from typing import Dict

def compute_shannon_wiener_index(species_counts: Dict[str, int]) -> float:
    """
    Calcule l'indice de diversité de Shannon-Wiener (H').
    
    H' = - sum(p_i * ln(p_i))
    où p_i est la proportion d'individus d'une espèce i par rapport au total.
    
    Args:
        species_counts: Dictionnaire {nom_espece: nombre_individus}
        
    Returns:
        float: L'indice de Shannon (H'). 0 si l'écosystème est vide ou ne contient qu'une espèce.
    """
    total_individuals = sum(species_counts.values())
    if total_individuals == 0:
        return 0.0
        
    h_index = 0.0
    for count in species_counts.values():
        if count > 0:
            p_i = count / total_individuals
            h_index -= p_i * math.log(p_i)
            
    return h_index
