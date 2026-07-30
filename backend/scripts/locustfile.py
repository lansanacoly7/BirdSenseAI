from locust import HttpUser, task, between

class BirdSenseUser(HttpUser):
    """
    Simulation d'un utilisateur appelant l'API BirdSense
    (notamment l'endpoint analytics)
    """
    # Attente aléatoire entre chaque requête (1 à 3 secondes)
    wait_time = between(1, 3)

    @task
    def get_analytics_stats(self):
        """Test de charge de l'endpoint des statistiques."""
        # On simule un appel GET sur l'endpoint des statistiques
        self.client.get("/api/v1/analytics/stats")
