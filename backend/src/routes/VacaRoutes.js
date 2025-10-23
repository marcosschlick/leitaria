import express from "express";
import { VacaController } from "../controllers/VacaController.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";

const vacaController = new VacaController();
const router = express.Router();

// vacas routes
router.get("/", authMiddleware, (req, res) =>
  vacaController.listarVacas(req, res)
);
router.get("/qr-code/:qrCode", authMiddleware, (req, res) =>
  vacaController.buscarVacaPorQrCode(req, res)
);
router.get("/search", authMiddleware, (req, res) =>
  vacaController.buscarVacasPorNome(req, res)
);
router.get("/brinco/:brinco", authMiddleware, (req, res) =>
  vacaController.buscarVacaPorBrinco(req, res)
);
router.post("/", authMiddleware, (req, res) =>
  vacaController.criarVaca(req, res)
);
router.post("/:vacaId/ordenha", authMiddleware, (req, res) =>
  vacaController.registrarOrdenha(req, res)
);
router.post("/:vacaId/cio", authMiddleware, (req, res) =>
  vacaController.registrarCio(req, res)
);
router.post("/:vacaId/inseminacao", authMiddleware, (req, res) =>
  vacaController.registrarInseminacao(req, res)
);
router.post("/:vacaId/prenhez", authMiddleware, (req, res) =>
  vacaController.confirmarPrenhez(req, res)
);
router.post("/:vacaId/parto", authMiddleware, (req, res) =>
  vacaController.registrarParto(req, res)
);
router.post("/:vacaId/peso", authMiddleware, (req, res) =>
  vacaController.registrarPeso(req, res)
);
router.get("/:vacaId/estatisticas", authMiddleware, (req, res) =>
  vacaController.getEstatisticasVaca(req, res)
);

export { router as vacaRoutes };
